local DAY = 86400
local MINUTE = 60
local SECOND = 1

local SETTINGS = {
    {duration = 5.5 * SECOND, r = 1, g = 0, b = 0, a = 1},
    {duration = 90.5 * SECOND, r = 1, g = 1, b = 0, a = 1},
    {duration = DAY, r = 1, g = 1, b = 1, a = 1},
    {duration = math.huge, r = 0.5, g = 0.5, b = 0.5, a = 1}
}

local cooldowns = {}

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

    local remain = cd.endTime - GetTime()
    local prev = nil

    for _, setting in ipairs(SETTINGS) do
        -- apply colors for the earliest value we're under
        if remain <= setting.duration then
            fs:SetTextColor(setting.r, setting.g, setting.b, setting.a)
            break
        -- and keep track of the previous one for scheduling updates
        else
            prev = setting
        end
    end

    -- schedule the next update, if we need to
    if prev then
        local sleep = math.max(remain - prev.duration, 0)

        if sleep > 0 then
            C_Timer.After(sleep, cd.update)
        end
    end
end

-- setup initial data when we first wee a cooldown
setmetatable(cooldowns, {
    __index = function(t, k)
        local fontString = getFontStringFromRegions(k:GetRegions())

        local v = {
            update = function()
                updateText(k)
            end,
            fontString = fontString,
            endTime = 0
        }

        t[k] = v

        return v
    end
})

-- hooks
local function setTimer(cooldown, start, duration)
    -- skip zero duration cooldowns
    if start <= 0 or duration <= 0 then
        return
    end

    local endTime = start + duration

    -- both the wow api and addons (especially auras) have a habit of resetting
    -- cooldowns every time there's an update to an aura we chack and do nothing
    -- if there's an exact start/duration match
    if cooldowns[cooldown].endTime ~= endTime then
        cooldowns[cooldown].endTime = endTime

        updateText(cooldown)
    end
end

local CooldownMT = getmetatable(ActionButton1Cooldown).__index

hooksecurefunc(CooldownMT, 'SetCooldown', function(cd, start, duration)
    if cd:IsForbidden() then
        return
    end

    setTimer(cd, start or 0, duration or 0)
end)

hooksecurefunc(CooldownMT, 'SetCooldownDuration', function(cd)
    if cd:IsForbidden() then
        return
    end

    local start, duration = cd:GetCooldownTimes()
    start = (start or 0) / 1000
    duration = (duration or 0) / 1000

    setTimer(cd, start, duration)
end)
