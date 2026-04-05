local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'

-- active cooldowns
local active = {}

-- text containers for repositioning cooldown font strings
local textContainers = {}
local ACTION_BUTTON_WIDTH = ActionButton1:GetWidth()

-- themer function cache
local themers = setmetatable({}, {
    __index = function(self, key)
        local themer = Addon:CreateThemer(Addon.db.profile.themes[key])

        self[key] = themer

        return themer
    end
})

local function onCooldownShow(cooldown)
    if issecretvalue(cooldown) then return end

    active[cooldown] = true
end

local function onCooldownHide(cooldown)
    if issecretvalue(cooldown) then return end

    active[cooldown] = nil
end

local function onCooldownSizeChanged(cooldown, width)
    if not canaccessvalue(width) then return end

    local scale = width / ACTION_BUTTON_WIDTH
    if scale > 0 then
        cooldown:GetCountdownFontString():SetScale(scale)
    end
end

local function onCooldownStart(cooldown)
    if issecretvalue(cooldown) or cooldown.noCooldownCount then return end

    if not cooldown.tullaCTC then
        cooldown:HookScript("OnShow", onCooldownShow)
        cooldown:HookScript("OnHide", onCooldownHide)
        cooldown:HookScript('OnSizeChanged', onCooldownSizeChanged)
        cooldown:GetCountdownFontString():SetSmoothScaling(true)

        cooldown.tullaCTC = true
    end

    -- HACK: cooldown text appears below action button hotkey and count text
    -- fix this by reparenting the text to a container with a higher frame
    -- level than the base text overlay container
    local parent = cooldown:GetParent()
    if parent and parent.TextOverlayContainer and not InCombatLockdown() then
        local container = textContainers[cooldown]
        if not container then
            container = CreateFrame('Frame', nil, cooldown)

            container:SetAllPoints(cooldown)
            container:SetFrameLevel(777)
            cooldown:GetCountdownFontString():SetParent(container)

            textContainers[cooldown] = container
        end
    end

    local func = themers[Addon:GetThemeName(cooldown)]
    func(cooldown)
end

local function getActiveTheme(cooldown)
    if issecretvalue(cooldown) then return end

    local themeName = Addon:GetThemeName(cooldown)
    local theme = Addon.db.profile.themes[themeName]

    if theme.enabled then
        return theme
    end
end

function Addon:OnLoad()
    -- initialize db
    local db = LibStub('AceDB-3.0'):New(DB_NAME, self:GetDBDefaults(), DEFAULT)

    db.RegisterCallback(self, 'OnProfileChanged', 'Refresh')
    db.RegisterCallback(self, 'OnProfileCopied', 'Refresh')
    db.RegisterCallback(self, 'OnProfileReset', 'Refresh')

    self.db = db

    -- add a handler for loading the settings panel
    self.frame = CreateFrame("Frame", nil, SettingsPanel)
    self.frame.owner = self

    self.frame:SetScript("OnShow", function(frame)
        C_AddOns.LoadAddOn(AddonName .. "_Config")
        frame:SetScript("OnShow", nil)
    end)

    -- setup hooks
    local CooldownMT = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(CooldownMT, 'SetCooldown', onCooldownStart)
    hooksecurefunc(CooldownMT, 'SetCooldownDuration', onCooldownStart)
    hooksecurefunc(CooldownMT, 'SetCooldownFromDurationObject', onCooldownStart)
    hooksecurefunc(CooldownMT, 'SetCooldownFromExpirationTime', onCooldownStart)
    hooksecurefunc(CooldownMT, 'SetCooldownUNIX', onCooldownStart)

    -- setup enforcers (hooks that apply our settings)
    local function lock(func)
        local running = false
        return function(...)
            if not running then
                running = true
                func(...)
                running = false
            end
        end
    end

    local function enforceCooldownSetting(method, setting)
        hooksecurefunc(CooldownMT, method, lock(function(cooldown, value)
            local theme = getActiveTheme(cooldown)
            if not (theme and theme.themeText) then return end

            if theme[setting] == "always" then
                if issecretvalue(value) or not value then
                    cooldown[method](cooldown, true)
                end
            elseif theme[setting] == "never" then
                if issecretvalue(value) or value then
                    cooldown[method](cooldown, false)
                end
            end
        end))
    end

    enforceCooldownSetting('SetDrawBling', 'drawBling')
    enforceCooldownSetting('SetDrawEdge', 'drawEdge')
    enforceCooldownSetting('SetDrawSwipe', 'drawSwipe')
    enforceCooldownSetting('SetReverse', 'reverse')
    enforceCooldownSetting('SetUseAuraDisplayTime', 'useAuraDisplayTime')

    hooksecurefunc(CooldownMT, 'SetSwipeColor', lock(function(cooldown, r, g, b, a)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeCooldown and theme.themeSwipeColor) then
            return
        end

        local cR, cG, cB, cA = Addon.HexToRGBA(theme.swipeColor)
        if issecretvalue(r) or not (r == cR and g == cG and b == cB and a == cA) then
            cooldown:SetSwipeColor(cR, cG, cB, cA)
        end
    end))

    hooksecurefunc(CooldownMT, 'SetHideCountdownNumbers', lock(function(cooldown, hide)
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
    end))

    -- setup launcher commands
    local function showOptionsFrame()
        if C_AddOns.LoadAddOn(AddonName .. '_Config') then
            Addon:OpenOptions()
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
    SlashCmdList[AddonName] = function(msg)
        local cmd = msg and msg:lower():trim()
        if cmd == "reset" then
            db:ResetProfile()
        elseif cmd == "version" then
            local version = C_AddOns.GetAddOnMetadata(AddonName, "Version")
            print("|cFFCC99FF" .. AddonName .. "|r " .. (version or UNKNOWN))
        else
            showOptionsFrame()
        end
    end

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

                    -- basic toggles for styling groups
                    themeText = true,
                    themeCooldown = false,

                    -- draw states
                    -- "default" | "always" | "never"
                    drawBling = "default",
                    drawEdge = "default",
                    drawSwipe = "default",
                    drawText = "default",
                    reverse = "default",
                    useAuraDisplayTime = "default",

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

                    -- tenths duration (0.1s)
                    tenthsThreshold = 0,

                    -- this currently controls the MM:SS display duration
                    abbrevThreshold = 90,

                    -- array of {threshold, color} entries
                    -- thresholds are specified in seconds and represent the
                    -- duration at which we want to start applying a color
                    textColors = {},

                    -- color for all durations (when no thresholds defined)
                    defaultTextColor = "FFFFFFFF",

                    -- swipe color
                    themeSwipeColor = false,
                    swipeColor = "000000CC",
                },

                -- default styling with conditional colors
                default = {
                    textColors = {
                        -- soon (0 - 5s)
                        { threshold = 5,    color = "FF6347FF" },
                        -- seconds (5 - 60s)
                        { threshold = 60,   color = "FFFF00FF" },
                        -- minutes (60 - 3600s)
                        { threshold = 3600, color = "FFFFFFFF" },
                    },

                    defaultTextColor = "AAAAAAFF"
                },

                none = {
                    enabled = false
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
    local refreshing
    local function restyleCooldowns()
        wipe(themers)

        for cooldown in pairs(active) do
            local themeName = Addon:GetThemeName(cooldown)
            local func = themers[themeName]

            func(cooldown)
        end

        refreshing = false
    end

    function Addon:Refresh()
        if not refreshing then
            refreshing = true
            C_Timer.After(0, restyleCooldowns)
        end
    end
end

EventUtil.ContinueOnAddOnLoaded(AddonName, function() Addon:OnLoad() end)

-- export the addon
_G[AddonName] = Addon
