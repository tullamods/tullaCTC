local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'

local hooked = {}

local themers = setmetatable({}, {
    __index = function(self, key)
        local themer = Addon:CreateThemer(Addon.db.profile.themes[key])

        self[key] = themer

        return themer
    end
})

local cooldowns = setmetatable({}, {
    __index = function(self, cooldown)
        local info = {
            cooldown = cooldown,
            themeName = Addon:GetThemeName(cooldown),
            text = cooldown:GetCountdownFontString()
        }

        self[cooldown] = info
        return info
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
    local startCooldown, stopCooldown, refreshCooldown

    startCooldown = function(cooldown, durationObject)
        if not hooked[cooldown] then
            cooldown:HookScript("OnShow", refreshCooldown)
            cooldown:HookScript("OnHide", stopCooldown)
            hooked[cooldown] = true
        end

        local info = cooldowns[cooldown]
        if info then
            info.duration = durationObject
            info.themeName = Addon:GetThemeName(cooldown)
            themers[info.themeName]:Apply(info)

            if durationObject then
                self:StartTicker()
            end
        end
    end

    stopCooldown = function(cooldown)
        cooldowns[cooldown] = nil
        if next(cooldowns) == nil then
            self:StopTicker()
        end
    end

    refreshCooldown = function(cooldown)
        startCooldown(cooldown, Addon:GetDuration(cooldown))
    end

    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(cooldown_mt, 'SetCooldown', function(cooldown, start, duration, modRate)
        local durationObject
        if notSecret(start, duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromStart(start, duration, modRate)
        else
            durationObject = Addon:GetDuration(cooldown)
        end

        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownDuration', function(cooldown, duration, modRate)
        local durationObject
        if notSecret(duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromStart(GetTime(), duration, modRate)
        else
            durationObject = Addon:GetDuration(cooldown)
        end

        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownFromDurationObject', function(cooldown, durationObject)
        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownFromExpirationTime', function(cooldown, expirationTime, duration, modRate)
        local durationObject
        if notSecret(expirationTime, duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromEnd(expirationTime, duration, modRate)
        else
            durationObject = self:GetDuration(cooldown)
        end

        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'Clear', stopCooldown)

    -- hooks to preserve styling overrides when other code tries to change them
    local function getActiveTheme(cooldown)
        local info = rawget(cooldowns, cooldown)
        if info and info.themeName then
            local theme = self.db.profile.themes[info.themeName]
            if theme.enabled then
                return theme
            end
        end
    end

    hooksecurefunc(cooldown_mt, 'SetHideCountdownNumbers', function(cooldown, hide)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeText) then return end

        if theme.drawText == "always" then
            if issecretvalue(hide) or hide then
                cooldown:SetHideCountdownNumbers(false)
            end
        elseif theme.drawText == "never" then
            if issecretvalue(hide) or not hide then
                cooldown:SetHideCountdownNumbers(true)
            end
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetDrawBling', function(cooldown, draw)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeText) then return end

        if theme.drawBling == "always" then
            if issecretvalue(draw) or not draw then
                cooldown:SetDrawBling(true)
            end
        elseif theme.drawBling == "never" then
            if issecretvalue(draw) or draw then
                cooldown:SetDrawBling(false)
            end
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetDrawEdge', function(cooldown, draw)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeCooldown) then return end

        if theme.drawEdge == "always" then
            if issecretvalue(draw) or not draw then
                cooldown:SetDrawEdge(true)
            end
        elseif theme.drawEdge == "never" then
            if issecretvalue(draw) or draw then
                cooldown:SetDrawEdge(false)
            end
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetDrawSwipe', function(cooldown, draw)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeCooldown) then return end

        if theme.drawSwipe == "always" then
            if issecretvalue(draw) or not draw then
                cooldown:SetDrawSwipe(true)
            end
        elseif theme.drawSwipe == "never" then
            if issecretvalue(draw) or draw then
                cooldown:SetDrawSwipe(false)
            end
        end
    end)

    hooksecurefunc(cooldown_mt, 'SetReverse', function(cooldown, reverse)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeCooldown) then return end

        if theme.reverse == "always" then
            if issecretvalue(reverse) or not reverse then
                cooldown:SetReverse(true)
            end
        elseif theme.reverse == "never" then
            if issecretvalue(reverse) or reverse then
                cooldown:SetReverse(false)
            end
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

-- note that colors are in fully qualified web color format #RRGGBBAA
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

                none = {
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
            if next(cooldowns) then
                Addon:OnUpdate()
            else
                self:StopTicker()
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
                    tremove(theme.textColors, i)
                end
            end
        end
    end
end

function Addon:OnUpdate()
    for cd, info in pairs(cooldowns) do
        local themeName = Addon:GetThemeName(cd)
        if themeName ~= info.themeName then
            info.themeName = themeName
            themers[themeName]:Apply(info)
        else
            themers[themeName]:ApplyColor(info)
        end
    end
end

function Addon:GetThemeName(cooldown)
    for _, rule in self:IterateActiveRules() do
        if rule.match(cooldown) then
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
    local function refreshCooldowns()
        refreshPending = false

        wipe(themers)
        for cooldown, info in pairs(cooldowns) do
            local themeName = Addon:GetThemeName(cooldown)

            info.themeName = themeName

            themers[themeName]:Apply(info)
        end
    end

    function Addon:Refresh()
        if not refreshPending then
            refreshPending = true
            C_Timer.After(0, refreshCooldowns)
        end
    end
end

EventUtil.ContinueOnAddOnLoaded(AddonName, function() Addon:OnLoad() end)

-- export the addon
_G[AddonName] = Addon
