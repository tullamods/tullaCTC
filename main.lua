local AddonName, Addon = ...
local DB_NAME = AddonName .. 'DB'
local SECRETS_ENABLED = type(canaccessvalue) == "function"
local L = Addon.L

local cooldownInfo = {}

-- handle floating point distance
local function equalish(x, y, precision)
    if x == y then
        return true
    end

    if x == nil or y == nil then
        return false
    end

    local scale = 10 ^ precision
    return Round(x * scale) == Round(y * scale)
end

local function parseDurationFromText(text)
    if text and text ~= "" then
        local days, hours, minutes, seconds

        seconds = tonumber(text)
        if seconds then
            return seconds
        end

        minutes, seconds = text:match(L.MMSS_PATTERN)
        if minutes and seconds then
            return tonumber(minutes) * 60 + tonumber(seconds)
        end

        minutes = text:match(L.MINUTES_PATTERN)
        if minutes then
            return tonumber(minutes) * 60
        end

        hours = text:match(L.HOURS_PATTERN)
        if hours then
            return tonumber(hours) * 3600
        end

        days = text:match(L.DAYS_PATTERN)
        if days then
            return tonumber(days) * 86400
        end
    end

    return nil
end

local function getFontStringFromRegions(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)

        if region:GetObjectType() == "FontString" then
            return region
        end
    end
end

local function updateText(cooldown)
    local info = cooldownInfo[cooldown]

    -- no text, quit early
    local fontString = info.fontString
    if not fontString and fontString:GetText() ~= "" then
        return
    end

    local theme, sleep = Addon:GetTheme(info)
    if not theme then
        return
    end

    local tFontHeight = theme.fontScale * info.fontHeight
    local fontName, fontHeight, fontFlags = fontString:GetFont()
    if not (theme.fontName == fontName and fontHeight == tFontHeight and theme.fontFlags == fontFlags) then
        if not fontString:SetFont(theme.fontName, tFontHeight, theme.fontFlags) then
            fontString:SetFont(STANDARD_TEXT_FONT, tFontHeight, theme.fontFlags)
        end
    end

    fontString:SetTextColor(theme.r, theme.g, theme.b, theme.a)

    local shadow = theme.shadow
    fontString:SetShadowColor(shadow.r, shadow.g, shadow.b, shadow.a)
    fontString:SetShadowOffset(shadow.x, shadow.y)

    -- Schedule the next update, if needed. C_Timer.After has an upper limit, so
    -- we don't bother updating the timer once it reaches the day threshold.(You
    -- probably shouldn't play WoW for 24  hours straight, so this is acceptable
    -- to me)
    if sleep and sleep > 0 and sleep < 86400 then
        C_Timer.After(sleep, info.update)
    end
end

-- setup initial data when we first see a cooldown
local durationMap = setmetatable({}, {
    __index = function(self, text)
        local duration = parseDurationFromText(text)
        self[text] = duration
        return duration
    end
})

setmetatable(cooldownInfo, {
    __index = function(self, cooldown)
        local fontString = getFontStringFromRegions(cooldown:GetRegions())
        local _, fontHeight = fontString:GetFont()

        local info = {
            update = function() updateText(cooldown) end,
            fontString = fontString,
            fontHeight = fontHeight,
            endTime = 0,
            parseDuration = function()
                return durationMap[fontString:GetText() or ""]
            end
        }

        self[cooldown] = info

        return info
    end
})

local function setTimer(cooldown, start, duration, modRate)
    -- skip zero duration cooldowns
    if start <= 0 or duration <= 0 or modRate <= 0 then
        return
    end

    local endTime = start + duration

    -- both the wow api and addons (especially auras) have a habit of resetting
    -- cooldowns every time there's an update to an aura we chack and do nothing
    -- if there's an exact start/duration match
    local info = cooldownInfo[cooldown]

    if not (equalish(endTime, info.endTime, 3) and info.modRate == modRate) then
        info.endTime = endTime
        info.modRate = modRate

        updateText(cooldown)
    end
end

local function scheduleSetTimer(cooldown)
    local info = cooldownInfo[cooldown]

    if not info.scheduled then
        info.scheduled = true

        C_Timer.After(GetTickTime(), function()
            info.scheduled = nil

            local duration = info.parseDuration()
            if duration then
                setTimer(cooldown, GetTime(), duration, 1)
            end
        end)
    end
end

function Addon:OnLoad()
    -- initialize db
    local db = LibStub('AceDB-3.0'):New(DB_NAME, self:GetDBDefaults(), DEFAULT)

    db.RegisterCallback(self, 'OnProfileChanged', 'Refresh')
    db.RegisterCallback(self, 'OnProfileCopied', 'Refresh')
    db.RegisterCallback(self, 'OnProfileReset', 'Refresh')

    self.db = db

    -- setup hooks
    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index

    if SECRETS_ENABLED then
        hooksecurefunc(cooldown_mt, 'SetCooldown', function(cooldown, start, duration, modRate)
            if cooldown:IsForbidden() then return end

            if canaccessvalue(start) then
                setTimer(cooldown, start or 0, duration or 0, modRate or 1)
            else
                duration = cooldownInfo[cooldown].parseDuration()
                if duration then
                    setTimer(cooldown, GetTime(), duration, 1)
                else
                    scheduleSetTimer(cooldown)
                end
            end
        end)

        hooksecurefunc(cooldown_mt, 'SetCooldownDuration', function(cooldown, duration, modRate)
            if cooldown:IsForbidden() then return end

            if canaccessvalue(duration) then
                setTimer(cooldown, GetTime(), duration or 0, modRate or 1)
            else
                duration = cooldownInfo[cooldown].parseDuration()
                if duration then
                    setTimer(cooldown, GetTime(), duration, 1)
                else
                    scheduleSetTimer(cooldown)
                end
            end
        end)
    else
        hooksecurefunc(cooldown_mt, 'SetCooldown', function(cd, start, duration, modRate)
            if cd:IsForbidden() then return end

            start = start or 0
            duration = duration or 0
            modRate = modRate or 1

            setTimer(cd, start, duration, modRate)
        end)

        hooksecurefunc(cooldown_mt, 'SetCooldownDuration', function(cd, duration, modRate)
            if cd:IsForbidden() then return end

            local start = GetTime()
            duration = duration or 0
            modRate = modRate or 1

            setTimer(cd, start, duration, modRate)
        end)
    end

    _G[AddonName] = self
    self.OnLoad = nil
end

function Addon:GetDBDefaults()
    return {
        profile = {
            themes = {
                ['**'] = {
                    -- what font to use (an actual path)
                    fontName = STANDARD_TEXT_FONT,

                    -- NONE | OUTLINE | THICKOUTLINE | MONOCHROME
                    fontFlags = 'OUTLINE',

                    fontScale = 1,

                    -- text color
                    r = 1,
                    g = 1,
                    b = 1,
                    a = 1,

                    -- shadow color and offset
                    shadow = {
                        -- color
                        r = 1,
                        g = 1,
                        b = 1,
                        a = 0,

                        -- offset
                        x = 0,
                        y = 0
                    }
                },

                soon = { r = 1, g = 0, b = 0, fontScale = 1.5 },
                seconds = { r = 1, g = 1, b = 0 },
                minutes = { r = 1, g = 1, b = 1 },
                hours = { r = .7, g = .7, b = .7, fontScale = .75 }
            },

            -- rules, in eval order
            rules = {
                { duration = 5,         theme = "soon" },
                { duration = 60,        theme = "seconds" },
                { duration = 3600,      theme = "minutes" },
                { duration = math.huge, theme = "hours" }
            }
        }
    }
end

function Addon:GetTheme(cooldownInfo)
    local remain = (cooldownInfo.endTime - GetTime()) / cooldownInfo.modRate
    if remain <= 0 then
        return
    end

    local nextRule
    for _, rule in ipairs(self.db.profile.rules) do
        if remain <= rule.duration then
            if nextRule then
                return self.db.profile.themes[rule.theme], (remain - nextRule.duration) * cooldownInfo.modRate
            end

            return self.db.profile.themes[rule.theme], 0
        else
            nextRule = rule
        end
    end
end

function Addon:Refresh()
    for cooldown in pairs(cooldownInfo) do
        updateText(cooldown)
    end
end

EventUtil.ContinueOnAddOnLoaded(AddonName, function() Addon:OnLoad() end)
