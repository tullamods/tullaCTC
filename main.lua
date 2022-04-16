local AddonName, AddonTable = ...
local Addon = LibStub('AceAddon-3.0'):NewAddon(AddonTable, AddonName)
local DB_NAME = AddonName .. 'DB'
local DB_SCHEMA_VERSION = 1

local cooldowns = {}

-- handle floating point distance
local function equalish(v1, v2, precision)
    if v1 == v2 then
        return true
    end

    if v1 == nil or v2 == nil then
        return false
    end

    local factor = math.pow(10, precision);

    return math.floor(v1 * factor + 0.5) == math.floor(v2 * factor + 0.5)
end

local function sanitizeModRate(value)
    value = tonumber(value) or 0

    if value <= 0 then
        value = 1
    end

    return value
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
    local cd = cooldowns[cooldown]

    -- no text, quit early
    local fs = cd.fontString
    if not fs and fs:GetText() ~= "" then
        return
    end

    local theme, sleep = Addon:GetTheme(cd)
    if not theme then
        return
    end

    local tFontHeight = theme.fontScale * cd.fontHeight
    local fontName, fontHeight, fontFlags = fs:GetFont()
    if not (theme.fontName == fontName and fontHeight == tFontHeight and theme.fontFlags == fontFlags) then
        if not fs:SetFont(theme.fontName, tFontHeight, theme.fontFlags) then
            fs:SetFont(STANDARD_TEXT_FONT, tFontHeight, theme.fontFlags)
        end
    end

    fs:SetTextColor(theme.r, theme.g, theme.b, theme.a)

    local shadow = theme.shadow
    fs:SetShadowColor(shadow.r, shadow.g, shadow.b, shadow.a)
    fs:SetShadowOffset(shadow.x, shadow.y)

    -- schedule the next update, if needed
    if sleep and sleep > 0 then
        C_Timer.After(sleep, cd.update)
    end
end

-- setup initial data when we first see a cooldown
setmetatable(cooldowns, {
    __index = function(t, k)
        local fs = getFontStringFromRegions(k:GetRegions())
        local _, fontHeight = fs:GetFont()

        local v = {
            update = function()
                updateText(k)
            end,
            fontString = fs,
            fontHeight = fontHeight,
            endTime = 0
        }

        t[k] = v

        return v
    end
})

-- hooks
local function setTimer(cooldown, start, duration, modRate)
    -- skip zero duration cooldowns
    if start <= 0 or duration <= 0 or modRate <= 0 then
        return
    end

    local endTime = start + duration

    -- both the wow api and addons (especially auras) have a habit of resetting
    -- cooldowns every time there's an update to an aura we chack and do nothing
    -- if there's an exact start/duration match
    local cd = cooldowns[cooldown]

    if not (equalish(endTime, cd.endTime, 3) and cd.modRate == modRate) then
        cd.endTime = endTime
        cd.modRate = modRate

        updateText(cooldown)
    end
end

function Addon:OnInitialize()
    -- initialize db
    local db = LibStub('AceDB-3.0'):New(DB_NAME, self:GetDBDefaults(), DEFAULT)

    db.RegisterCallback(self, 'OnProfileChanged', 'OnProfileChanged')
    db.RegisterCallback(self, 'OnProfileCopied', 'OnProfileChanged')
    db.RegisterCallback(self, 'OnProfileReset', 'OnProfileChanged')

    self.db = db

    -- setup hooks
    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(cooldown_mt, 'SetCooldown', function(cd, start, duration, modRate)
        if cd:IsForbidden() then
            return
        end

        start = tonumber(start) or 0
        duration = tonumber(duration) or 0
        modRate = sanitizeModRate(modRate)

        setTimer(cd, start, duration, modRate)
    end)

    hooksecurefunc(cooldown_mt, 'SetCooldownDuration', function(cd, duration, modRate)
        if cd:IsForbidden() then
            return
        end

        local start = GetTime()
        duration = tonumber(duration) or 0
        modRate = sanitizeModRate(modRate)

        setTimer(cd, start, duration, modRate)
    end)
end

function Addon:UpgradeDB()
    local dbVersion = self.db.global.dbVersion

    if dbVersion ~= DB_SCHEMA_VERSION then
        self.db.global.dbVersion = DB_SCHEMA_VERSION
    end

    local addonVersion = self.db.global.addonVersion
    if addonVersion ~= GetAddOnMetadata(AddonName, 'Version') then
        self.db.global.addonVersion = GetAddOnMetadata(AddonName, 'Version')
    end
end

function Addon:OnProfileChanged()
    self:Refresh()
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

                soon = {r = 1, g = 0, b = 0, fontScale = 1.5},
                seconds = {r = 1, g = 1, b = 0},
                minutes = {r = 1, g = 1, b = 1},
                hours = {r = .7, g = .7, b = .7, fontScale = .75}
            },

            -- rules, in eval order
            rules = {
                {duration = 5, theme = "soon"},
                {duration = 60, theme = "seconds"},
                {duration = 60 * 60, theme = "minutes"},
                {duration = math.huge, theme = "hours"}
            }
        }
    }
end

function Addon:GetTheme(cooldown)
    local remain = (cooldown.endTime - GetTime()) / cooldown.modRate
    if remain <= 0 then
        return
    end

    local nextRule
    for _, rule in ipairs(self.db.profile.rules) do
        if remain <= rule.duration then
            if nextRule then
                return self.db.profile.themes[rule.theme], (remain - nextRule.duration) * cooldown.modRate
            end

            return self.db.profile.themes[rule.theme], 0
        else
            nextRule  = rule
        end
    end
end

function Addon:Refresh()
    for cooldown in pairs(cooldowns) do
        updateText(cooldown)
    end
end