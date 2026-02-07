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
        if issecretvalue(cooldown) then return end

        local info = {
            cooldown = cooldown,
            -- some cooldowns (i'm looking at you, nameplates) aren't actually
            -- linked up with their parents before the cooldown is set
            name = Addon.GetRegionName(cooldown),
            themeName = Addon:GetThemeName(cooldown),
            text = cooldown:GetCountdownFontString()
        }

        self[cooldown] = info
        return info
    end
})

-- hopefully avoid repeatedly creating the same duration objects
local durations = setmetatable({}, {
    __call = function(self, endTime, duration, modRate)
        local key = ('%s:%s'):format(endTime, modRate or 1)

        local cached = self[key]
        if not cached then
            cached = C_DurationUtil.CreateDuration()
            self[key] = cached
        end

        cached:SetTimeFromEnd(endTime, duration, modRate)
        return cached
    end
})

local function handleUpdate()
    if next(cooldowns) then
        Addon:OnUpdate()
    elseif Addon.ticker then
        Addon.ticker:Cancel()
        Addon.ticker = nil
    end
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
        local info = cooldowns[cooldown]
        if not info then
            return
        end

        if not hooked[cooldown] then
            cooldown:HookScript("OnShow", refreshCooldown)
            cooldown:HookScript("OnHide", stopCooldown)
            hooked[cooldown] = true
        end

        info.duration = durationObject
        info.themeName = Addon:GetThemeName(cooldown)
        themers[info.themeName]:Apply(info)

        if durationObject and not Addon.ticker then
            Addon.ticker = C_Timer.NewTicker(0.1, handleUpdate)
        end
    end

    stopCooldown = function(cooldown)
        cooldowns[cooldown] = nil

        if Addon.ticker and not next(cooldowns) then
            Addon.ticker:Cancel()
            Addon.ticker = nil
        end
    end

    refreshCooldown = function(cooldown)
        if issecretvalue(cooldown) then return end

        local durationObject = Addon:GetDuration(cooldown)
        if not durationObject then
            local displayDuration = cooldown:GetCooldownDisplayDuration()
            if canaccessvalue(displayDuration) then
                local start, duration = cooldown:GetCooldownTimes()
                local modRate

                if displayDuration > 0 then
                    modRate = duration / displayDuration
                else
                    modRate = 1
                end

                durationObject = durations((start +  duration) / 1000, duration / 1000, modRate)
            end
        end

        startCooldown(cooldown, durationObject)
    end

    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(cooldown_mt, 'SetCooldown', function(cooldown, start, duration, modRate)
        local durationObject
        if canaccessallvalues(start, duration, modRate) then
            durationObject = durations(start + duration, duration, modRate)
        else
            durationObject = Addon:GetDuration(cooldown)
        end

        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownDuration', function(cooldown, duration, modRate)
        local durationObject
        if canaccessallvalues(duration, modRate) then
            durationObject = durations(GetTime() + duration, duration, modRate)
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
        if canaccessallvalues(expirationTime, duration, modRate) then
            durationObject = durations(expirationTime, duration, modRate)
        else
            durationObject = Addon:GetDuration(cooldown)
        end

        startCooldown(cooldown, durationObject)
    end)

    hooksecurefunc(cooldown_mt, 'Clear', stopCooldown)

    -- hooks to preserve styling overrides when other code tries to change them
    local function getActiveTheme(cooldown)
        local info = rawget(cooldowns, cooldown)
        if info and info.themeName then
            local theme = Addon.db.profile.themes[info.themeName]
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

    local function enforceCooldownSetting(method, setting)
        hooksecurefunc(cooldown_mt, method, function(cooldown, value)
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
        end)
    end

    enforceCooldownSetting('SetDrawBling', 'drawBling')
    enforceCooldownSetting('SetDrawEdge', 'drawEdge')
    enforceCooldownSetting('SetDrawSwipe', 'drawSwipe')
    enforceCooldownSetting('SetReverse', 'reverse')
    enforceCooldownSetting('SetUseAuraDisplayTime', 'useAuraDisplayTime')

    hooksecurefunc(cooldown_mt, 'SetSwipeColor', function(cooldown, r, g, b, a)
        local theme = getActiveTheme(cooldown)
        if not (theme and theme.themeCooldown and theme.themeSwipeColor) then return end

        local cR, cG, cB, cA = Addon.HexToRGBA(theme.swipeColor)
        if issecretvalue(r) or not (r == cR and g == cG and b == cB and a == cA) then
            cooldown:SetSwipeColor(cR, cG, cB, cA)
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
        -- try and retrieve the name of a cooldown if we don't know it yet
        local name = info.name
        if not name then
            name = Addon.GetRegionName(cd)
            if name then
                info.name = name

                local themeName = Addon:GetThemeName(cd)
                if themeName ~= info.themeName then
                    info.themeName = themeName
                    themers[themeName]:Apply(info)
                else
                    themers[themeName]:ApplyColor(info)
                end
            else
                themers[info.themeName]:ApplyColor(info)
            end
        else
            themers[info.themeName]:ApplyColor(info)
        end
    end

    -- cleanup: purge expired durations from cache
    for key, duration in pairs(durations) do
        if duration:IsZero() then
            durations[key] = nil
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
