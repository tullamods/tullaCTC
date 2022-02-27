local SECOND = 1
local MINUTE = SECOND * 60
local HOUR = MINUTE * 60

-- TODO: move to saved settings
local STYLES = {
    -- 10s or less
    {duration = 10 * SECOND, r = 1, g = 0, b = 0, a = 1},

    -- 90s
    {duration = 90 * SECOND, r = 1, g = 1, b = 0, a = 1},

    -- hours
    {duration = HOUR, r = 1, g = 1, b = 1, a = 1},

    -- default case
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
    local nextStyle = nil

    for _, style in ipairs(STYLES) do
        -- apply colors for the earliest value we're under
        if remain <= style.duration then
            fs:SetTextColor(style.r, style.g, style.b, style.a)
            -- TODO: font/scale should be easy to apply, too
            break
        -- and keep track of the previous one, so that we know how long to
        -- wait for the next style update
        else
            nextStyle = style
        end
    end

    -- schedule the next update, if needed
    local sleep = nextStyle and math.max(remain - nextStyle.duration, 0) or 0
    if sleep > 0 then
        C_Timer.After(sleep, cd.update)
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

    -- TODO: test excluding GCD for perf/memory usage reasons
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
