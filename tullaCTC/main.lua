local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'

local active = {}
local hooked = {}
local themers = setmetatable({}, {
    __index = function(t, k)
        local themer = Addon:CreateThemer(Addon.db.profile.themes[k])

        t[k] = themer

        return themer
    end
})

local function notSecret(...)
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        if issecretvalue(value) then
            return false
        end
    end
    return true
end

function Addon:OnLoad()
    -- initialize db
    local db = LibStub('AceDB-3.0'):New(DB_NAME, self:GetDBDefaults(), DEFAULT)

    db.RegisterCallback(self, 'OnProfileChanged', 'Refresh')
    db.RegisterCallback(self, 'OnProfileCopied', 'Refresh')
    db.RegisterCallback(self, 'OnProfileReset', 'Refresh')

    self.db = db
    self:MigrateTextColors()

    -- setup hooks
    local initCooldown, stopCooldown, refreshCooldown

    initCooldown = function(cooldown, durationObject)
        if not hooked[cooldown] then
            cooldown:HookScript("OnShow", refreshCooldown)
            cooldown:HookScript("OnHide", stopCooldown)
            hooked[cooldown] = true
        end

        local theme = self:GetThemeName(cooldown)
        if not theme then
            return
        end

        local cdInfo = active[cooldown]
        if not cdInfo then
            cdInfo = {
                cooldown = cooldown,
                duration = durationObject,
                theme = theme,
            }

            active[cooldown] = cdInfo
        else
            cdInfo.duration = durationObject
            cdInfo.theme = theme
        end

        themers[theme]:Apply(cdInfo)

        if durationObject and not self.ticker then
            self:StartTicker()
        end
    end

    stopCooldown = function(cooldown)
        active[cooldown] = nil

        if next(active) == nil then
            self:StopTicker()
        end
    end

    refreshCooldown = function(cooldown)
        if not (active[cooldown] or cooldown:IsForbidden()) then
            initCooldown(cooldown, Addon:GetDuration(cooldown))
        end
    end

    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(cooldown_mt, 'SetCooldown', function(cooldown, start, duration, modRate)
        if cooldown:IsForbidden() then return end

        local durationObject
        if notSecret(start, duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromStart(start, duration, modRate)
        else
            durationObject = Addon:GetDuration(cooldown)
        end

        initCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownDuration', function(cooldown, duration, modRate)
        if cooldown:IsForbidden() then return end

        local durationObject
        if notSecret(duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromStart(GetTime(), duration, modRate)
        else
            durationObject = Addon:GetDuration(cooldown)
        end

        initCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownFromDurationObject', function(cooldown, durationObject)
        if cooldown:IsForbidden() then return end

        initCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownFromExpirationTime', function(cooldown, expirationTime, duration, modRate)
        if cooldown:IsForbidden() then return end

        local durationObject
        if notSecret(expirationTime, duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromEnd(expirationTime, duration, modRate)
        else
            durationObject = self:GetDuration(cooldown)
        end

        initCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'Clear', stopCooldown)

    -- hooks to preserve styling overrides when other code tries to change them
    local function getThemeConfig(cooldown)
        if cooldown:IsForbidden() then return end

        local cdInfo = active[cooldown]
        if not cdInfo or not cdInfo.theme then return end

        return self.db.profile.themes[cdInfo.theme]
    end

    hooksecurefunc(cooldown_mt, 'SetHideCountdownNumbers', function(cooldown, hide)
        local themeConfig = getThemeConfig(cooldown)
        if not (themeConfig and themeConfig.enabled and themeConfig.themeText) then return end

        if themeConfig.drawText == "always" and hide then
            cooldown:SetHideCountdownNumbers(false)
        elseif themeConfig.drawText == "never" and not hide then
            cooldown:SetHideCountdownNumbers(true)
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetDrawBling', function(cooldown, draw)
        local themeConfig = getThemeConfig(cooldown)
        if not (themeConfig and themeConfig.enabled and themeConfig.themeCooldown) then return end

        if themeConfig.drawBling == "always" and not draw then
            cooldown:SetDrawBling(true)
        elseif themeConfig.drawBling == "never" and draw then
            cooldown:SetDrawBling(false)
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetDrawEdge', function(cooldown, draw)
        local themeConfig = getThemeConfig(cooldown)
        if not (themeConfig and themeConfig.enabled and themeConfig.themeCooldown) then return end

        if themeConfig.drawEdge == "always" and not draw then
            cooldown:SetDrawEdge(true)
        elseif themeConfig.drawEdge == "never" and draw then
            cooldown:SetDrawEdge(false)
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetDrawSwipe', function(cooldown, draw)
        local themeConfig = getThemeConfig(cooldown)
        if not (themeConfig and themeConfig.enabled and themeConfig.themeCooldown) then return end

        if themeConfig.drawSwipe == "always" and not draw then
            cooldown:SetDrawSwipe(true)
        elseif themeConfig.drawSwipe == "never" and draw then
            cooldown:SetDrawSwipe(false)
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetReverse', function(cooldown, reverse)
        local themeConfig = getThemeConfig(cooldown)
        if not (themeConfig and themeConfig.enabled and themeConfig.themeCooldown) then return end

        if themeConfig.reverse == "always" and not reverse then
            cooldown:SetReverse(true)
        elseif themeConfig.reverse == "never" and reverse then
            cooldown:SetReverse(false)
        end
    end)

    -- setup launcher commands
    local function showOptionsFrame()
        if C_AddOns.LoadAddOn(AddonName .. '_Config') then
            local dialog = LibStub('AceConfigDialog-3.0')

            dialog:Open(AddonName)
            dialog:SelectGroup(AddonName, "themes", DEFAULT)

            return true
        end
        return false
    end

	if AddonCompartmentFrame then
		AddonCompartmentFrame:RegisterAddon{
			text = C_AddOns.GetAddOnMetadata(AddonName, "Title"),
			icon = C_AddOns.GetAddOnMetadata(AddonName, "IconTexture"),
			func = showOptionsFrame,
		}
	end

    -- setup slash commands
    SlashCmdList[AddonName] = showOptionsFrame
    SLASH_tullaCTC1 = '/' .. AddonName:lower()
    SLASH_tullaCTC2 = '/tctc'
end

function Addon:GetDBDefaults()
    return {
        profile = {
            themes = {
                ['**'] = {
                    -- global theme toggle
                    enabled = true,

                    -- basic on/of switches for styling groups
                    themeText = true,
                    themeCooldown = false,

                    -- draw states
                    -- "default" | "always" | "never"
                    drawBling = "default",
                    drawEdge = "default",
                    drawSwipe = "default",
                    drawText = "default",
                    reverse = "default",

                    -- cooldown text font settings
                    -- font is a LSM font ID
                    font = "Friz Quadrata TT",
                    fontFlags = 'OUTLINE',
                    -- setting a font size to zero will just let the ui handle sizing
                    fontSize = 0,

                    -- text positioning
                    point = "CENTER",
                    offsetX = 0,
                    offsetY = 0,

                    -- text shadow
                    shadowColor = "FFFFFF00",
                    shadowX = 0,
                    shadowY = 0,

                    -- how long a cooldown must be in order to display text
                    minDuration = 3,

                    -- this currently controls the MM:SS display duration
                    abbrevThreshold = 90,

                    -- array of {threshold, color} entries
                    -- thresholds are specified in seconds and represent the
                    -- duration at which we want to start applying a color
                    textColors = {},
                    -- color for all durations (when no thresholds defined)
                    defaultTextColor = "FFFFFFFF",
                },

                -- default styling with conditional colors
                default = {
                    displayName = DEFAULT,
                    fontSize = 18,
                    textColors = {
                        -- soon (0 - 5s)
                        { threshold = 5, color = "FF6347FF" },
                        -- seconds (5 - 60s)
                        { threshold = 60, color = "FFFF00FF" },
                        -- minutes (60 - 3600s)
                        { threshold = 3600, color = "FFFFFFFF" },
                    },

                    defaultTextColor = "AAAAAAFF"
                },

                disable = {
                    displayName = DISABLE,
                    enabled  = false
                }
            },

            -- rule to theme mapping
            rules = {
                ['*'] = {
                    enabled = nil,
                    theme = "default"
                }
            }
        }
    }
end

function Addon:StartTicker()
    if not self.ticker then
        self.ticker = C_Timer.NewTicker(0.1, function(ticker)
            if not ticker:IsCancelled() then
                Addon:UpdateAll()
            end
        end)
    end
end

function Addon:StopTicker()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

function Addon:MigrateTextColors()
    local themes = self.db.profile.themes
    if not themes then return end

    for _, theme in pairs(themes) do
        if type(theme) == "table" and theme.textColors then
            for i = #theme.textColors, 1, -1 do
                local entry = theme.textColors[i]
                if entry.threshold == math.huge then
                    theme.defaultTextColor = entry.color
                    table.remove(theme.textColors, i)
                end
            end
        end
    end
end

function Addon:UpdateAll()
    for _, cdInfo in pairs(active) do
        local theme = cdInfo.them
        if theme then
            themers[theme]:UpdateColor(cdInfo)
        else
            active[cdInfo.cooldown] = nil
            if next(active) == nil then
                self:StopTicker()
            end
        end
    end
end

function Addon:GetThemeName(cooldown)
    for _, rule in self:IterateRules() do
        if self:IsRuleEnabled(rule) and rule.match(cooldown) then
            local settings = self.db.profile.rules[rule.id]
            return settings and settings.theme or "default"
        end
    end

    return "default"
end

function Addon:IsRuleEnabled(rule)
    local config = self.db.profile.rules[rule.id]
    if config.enabled ~= nil then
        return config.enabled
    end
    return rule.enabled == true
end

-- throttle refresh since it can be called a bunch by the config ui
do
    local refreshPending
    local function refresh()
        refreshPending = false
        wipe(themers)

        for _, cooldownInfo in pairs(active) do
            local theme = Addon:GetThemeName(cooldownInfo.cooldown)

            cooldownInfo.theme = theme

            if theme then
                themers[theme]:Apply(cooldownInfo)
            end
        end
    end

    function Addon:Refresh()
        if not refreshPending then
            refreshPending = true
            C_Timer.After(0, refresh)
        end
    end
end

EventUtil.ContinueOnAddOnLoaded(AddonName, function() Addon:OnLoad() end)

-- export the addon
_G[AddonName] = Addon
