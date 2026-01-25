local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'

local active = {}
local hooked = {}
local themes = setmetatable({}, {
    __index = function(t, themeName)
        if not themeName then return end

        local settings =  Addon.db.profile.themes[themeName]
        local theme = Addon.CreateTheme(settings)

        t[themeName] = theme

        return theme
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
    local startCooldown, stopCooldown, refreshCooldown

    startCooldown = function(cooldown, durationObject)
        if not durationObject then return end

        if not hooked[cooldown] then
            cooldown:HookScript("OnShow", refreshCooldown)
            cooldown:HookScript("OnHide", stopCooldown)
            hooked[cooldown] = true
        end

        local themeName = self:GetThemeName(cooldown)
        if not themeName then return end

        local fontString = cooldown:GetCountdownFontString()
        if not fontString then return end

        local cooldownInfo = active[cooldown]
        if not cooldownInfo then
            cooldownInfo = {
                cooldown = cooldown,
                duration = durationObject,
                themeName = themeName,
                fontString = fontString
            }

            active[cooldown] = cooldownInfo
        else
            cooldownInfo.duration = durationObject
            cooldownInfo.themeName = themeName
        end

        local theme = themes[themeName]
        theme:Apply(cooldownInfo)
        theme:UpdateColor(cooldownInfo)

        if not self.ticker then
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
            startCooldown(cooldown, Addon:GetDuration(cooldown))
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

        startCooldown(cooldown, durationObject)
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

        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownFromDurationObject', function(cooldown, durationObject)
        if cooldown:IsForbidden() then return end

        startCooldown(cooldown, durationObject)
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

        startCooldown(cooldown, durationObject)
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
    SLASH_tullaCTC1 = '/tullactc'
    SLASH_tullaCTC2 = '/tctc'
end

function Addon:GetDBDefaults()
    return {
        profile = {
            themes = {
                -- defaults inherited by all themes
                ['**'] = {
                    font = "Friz Quadrata TT",
                    fontFlags = 'OUTLINE',
                    fontSize = 18,
                    point = "CENTER",
                    offsetX = 0,
                    offsetY = 0,
                    forceShowText = true,

                    shadowColor = "FFFFFF00",
                    shadowX = 0,
                    shadowY = 0,
                    abbrevThreshold = 90,
                    minDuration = 3,
                    curves = {
                        color = {
                            [5] = "FF6347FF",
                            [60] = "FFFF00FF",
                            [3600] = "FFFFFFFF",
                            [14400] = "AAAAAAFF"
                        }
                    }
                },

                default = {
                    displayName = DEFAULT
                }
            },

            rules = {
                -- defaults inherited by all rules
                ['**'] = {
                    theme = "default",
                    enabled = true
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
    for _, cooldownInfo in pairs(active) do
        local theme = themes[cooldownInfo.themeName]
        theme:UpdateColor(cooldownInfo)
    end
end

function Addon:Refresh()
    wipe(themes)

    for _, cooldownInfo in pairs(active) do
        local theme = themes[cooldownInfo.themeName]
        theme:Apply(cooldownInfo)
    end
end

EventUtil.ContinueOnAddOnLoaded(AddonName, function() Addon:OnLoad() end)

-- export the addon
_G[AddonName] = Addon
