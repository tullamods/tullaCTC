local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'

-- active cooldowns
local active = {}

-- text containers for repositioning cooldown font strings
local textContainers = {}
local SCALE_BASE = Round(ActionButton1.cooldown:GetWidth())

-- integer id generation to give us a stable not secret identifier
-- we can use for the active table
local nextid
do
    local id = 0
    nextid = function() id = id + 1; return id; end
end

-- themer function cache
local themers = setmetatable({}, {
    __index = function(self, key)
        local themer = Addon:CreateThemer(Addon.db.profile.themes[key])

        self[key] = themer

        return themer
    end
})

local function getTheme(cooldown)
    if cooldown.noCooldownCount then return end

    local themeName = Addon:GetThemeName(cooldown)
    local theme = Addon.db.profile.themes[themeName]

    if theme.enabled then
        return theme
    end
end

local function onCooldownSizeChanged(cooldown, width)
    local theme = getTheme(cooldown)
    local scale, alpha = 1, 1

    if theme and canaccessvalue(width) and width > 0 then
        scale = theme.scaleText and (Round(width) / SCALE_BASE) or 1
        alpha = Round(scale * 100) >= Round(theme.minScale * 100) and 1 or 0
    end

    local fs = cooldown:GetCountdownFontString()
    fs:SetAlpha(alpha)
    fs:SetScale(scale)
end

local function onCooldownStop(cooldown)
    local cooldownID = cooldown.tullaCTC
    if cooldownID then
        active[cooldownID] = nil
    end
end

local function onCooldownStart(cooldown)
    if cooldown.noCooldownCount then
        onCooldownStop(cooldown)
        return
    end

    local cooldownID = cooldown.tullaCTC
    if cooldownID == nil then
        cooldownID = nextid()
        cooldown.tullaCTC = cooldownID
        cooldown:HookScript('OnSizeChanged', onCooldownSizeChanged)
        cooldown:HookScript('OnCooldownDone', onCooldownStop)
    end

    -- HACK: cooldown text appears below action button hotkey and count text
    -- fix this by reparenting the text to a container with a higher frame
    -- level than the base text overlay container
    local parent = cooldown:GetParent()
    if parent and parent.TextOverlayContainer and not InCombatLockdown() then
        local container = textContainers[cooldownID]
        if not container then
            container = CreateFrame('Frame', nil, cooldown)

            container:SetAllPoints(cooldown)
            container:SetFrameLevel(777)
            cooldown:GetCountdownFontString():SetParent(container)

            textContainers[cooldownID] = container
        end
    end

    themers[Addon:GetThemeName(cooldown)](cooldown)
    onCooldownSizeChanged(cooldown, cooldown:GetWidth())
    active[cooldownID] = cooldown
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
    hooksecurefunc(CooldownMT, 'Clear', onCooldownStop)

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
            local theme = getTheme(cooldown)
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

    hooksecurefunc(CooldownMT, 'SetSwipeColor', lock(function(cooldown, r, g, b, a)
        local theme = getTheme(cooldown)
        if not (theme and theme.themeCooldown and theme.themeSwipeColor) then
            return
        end

        local cR, cG, cB, cA = Addon.HexToRGBA(theme.swipeColor)
        if issecretvalue(r) or not (r == cR and g == cG and b == cB and a == cA) then
            cooldown:SetSwipeColor(cR, cG, cB, cA)
        end
    end))

    hooksecurefunc(CooldownMT, 'SetHideCountdownNumbers', lock(function(cooldown, hide)
        local theme = getTheme(cooldown)
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

    hooksecurefunc('CooldownFrame_SetDisplayAsPercentage', function(cooldown)
        if cooldown.noCooldownCount then return end

        cooldown.noCooldownCount = true
        cooldown:SetHideCountdownNumbers(true)
    end)

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

                    -- text scaling and visibility
                    scaleText = false,
                    minScale = 0,

                    -- how long a cooldown must be in order to display text
                    minDuration = 3,

                    -- tenths duration (0.1)
                    tenthsThreshold = 0,

                    -- minutes format (1m)
                    minutesThreshold = 60,

                    -- mm:ss format (12:00)
                    abbrevThreshold = 90,

                    -- hours format (4h)
                    hoursThreshold = 3600,

                    -- days format (7d)
                    daysThreshold = 86400,

                    -- weeks format (1w)
                    weeksThreshold = 604800,

                    -- key of Enum.NumericRuleFormatRounding
                    roundingMode = "Nearest",

                    -- show zero for rounding modes that would show empty at threshold 0
                    showZero = false,

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

                omnicc = {
                    fontSize = 18,
                    drawText = "always",
                    minDuration = 2,
                    abbrevThreshold = 0,
                    scaleText = true,
                    minScale = 0.5,

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

        for _, cooldown in pairs(active) do
            local themeName = Addon:GetThemeName(cooldown)
            local func = themers[themeName]

            onCooldownSizeChanged(cooldown, cooldown:GetWidth())

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
