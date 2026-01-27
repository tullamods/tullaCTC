local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'

local active = {}
local hooked = {}
local themers = setmetatable({}, {
    __index = function(t, k)
        local themer = Addon.CreateThemer(Addon.db.profile.themes[k])

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
                    fontSize = 18,

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
                },

                -- default styling with conditional colors
                default = {
                    displayName = DEFAULT,

                    textColors = {
                        -- soon (0 - 5s)
                        { threshold = 5, color = "FF6347FF" },
                        -- minute (5 to 60)
                        { threshold = 60, color = "FFFF00FF" },
                        -- hours (61 to 3600)
                        { threshold = 3600, color = "FFFFFFFF" },
                        -- the rest (3600+)
                        { threshold = math.huge, color = "AAAAAAFF" },
                    }
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

function Addon:UpdateAll()
    for _, cdInfo in pairs(active) do
        themers[cdInfo.theme]:UpdateColor(cdInfo)
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

function Addon:Refresh()
    wipe(themers)

    for _, cooldownInfo in pairs(active) do
        local theme = themers[cooldownInfo.themeName]
        theme:Apply(cooldownInfo)
    end
end

EventUtil.ContinueOnAddOnLoaded(AddonName, function() Addon:OnLoad() end)

-- export the addon
_G[AddonName] = Addon
