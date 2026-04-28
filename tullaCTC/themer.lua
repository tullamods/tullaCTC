-- Themer is a runtime object that styles cooldowns

local _, Addon = ...

local MINUTE = 60
local HOUR = MINUTE * 60
local DAY = HOUR * 24
local WEEK = DAY * 7
local NOOP = function() end

-- converts draw state enum values into a bool|nil
local function getDrawStateBool(state)
    if state == "always" then
        return true
    elseif state == "never" then
        return false
    end
    return nil
end

local function thresholdComparer(a, b)
    return a.threshold < b.threshold
end

-- converts a tullaCTC config into a sorted array of formatter breakpoints
local function getFormatBreakpoints(config)
    local roundingMode = Enum.NumericRuleFormatRounding[config.roundingMode]
    if roundingMode == nil then
        roundingMode = Enum.NumericRuleFormatRounding.Nearest
    end

    local points = {}
    if (config.tenthsThreshold or 0) > 0 then
        tinsert(points, {
            threshold = 0,
            format = '%.1f',
            rounding = roundingMode,
            step = 0.1
        })

        tinsert(points, {
            threshold = config.tenthsThreshold,
            format = '%d',
            rounding = roundingMode,
            step = 1
        })
    elseif roundingMode == Enum.NumericRuleFormatRounding.Up then
        tinsert(points, {
            threshold = 0,
            format = '%d',
            rounding = roundingMode,
            step = 1
        })
    elseif roundingMode == Enum.NumericRuleFormatRounding.Down then
        if config.showZero then
            tinsert(points, {
                threshold = 0,
                format = '%d',
                rounding = roundingMode,
                step = 1
            })
        else
            tinsert(points, {
                threshold = 0,
                format = '',
                rounding = roundingMode,
                step = 1
            })

            tinsert(points, {
                threshold = 1,
                format = '%d',
                rounding = roundingMode,
                step = 1
            })
        end
    else
        if config.showZero then
            tinsert(points, {
                threshold = 0,
                format = '%d',
                rounding = roundingMode,
                step = 1
            })
        else
            tinsert(points, {
                threshold = 0,
                format = '',
                rounding = roundingMode,
                step = 1
            })

            tinsert(points, {
                threshold = 0.5,
                format = '%d',
                rounding = roundingMode,
                step = 1
            })
        end
    end

    local mmssThreshold = config.abbrevThreshold or 0
    if mmssThreshold >= MINUTE then
        tinsert(points, {
            threshold = config.minutesThreshold,
            format = '%d:%02d',
            rounding = roundingMode,
            step = 1,
            components = { { div = MINUTE } , { mod = MINUTE } },
        })

        tinsert(points, {
            threshold = mmssThreshold,
            format = '%dm',
            components = { { div = MINUTE, rounding = roundingMode, step = 1 } },
        })
    else
        tinsert(points, {
            threshold = config.minutesThreshold,
            format = '%dm',
            components = { { div = MINUTE, rounding = roundingMode, step = 1 } },
        })
    end

    local minutesThreshold = points[#points].threshold

    local hoursThreshold = config.hoursThreshold or 0
    if hoursThreshold > minutesThreshold then
        tinsert(points, {
            threshold = hoursThreshold,
            format = '%dh',
            components = { { div = HOUR, rounding = roundingMode, step = 1 } },
        })
    end

    local daysThreshold = config.daysThreshold or 0
    if daysThreshold > hoursThreshold then
        tinsert(points, {
            threshold = daysThreshold,
            format = '%dd',
            components = { { div = DAY, rounding = roundingMode, step = 1 } },
        })
    end

    local weeksThreshold = config.weeksThreshold or 0
    if weeksThreshold > daysThreshold then
        tinsert(points, {
            threshold = weeksThreshold,
            format = '%dw',
            components = { { div = WEEK, rounding = roundingMode, step = 1 } },
        })
    end

    return points
end

-- convert's tullaCTC's config sttings into a sorted array of color breakpoints
local function getColorBreakpoints(config)
    local points = {}

    local textColors = config.textColors
    if textColors and #textColors > 0 then
        for i = 1, #textColors do
            local entry = textColors[i]

            points[i] = {
                threshold = entry.threshold,
                color = Addon.CreateColor(entry.color)
            }
        end

        points[#points+1] = {
            threshold = math.huge,
            color = Addon.CreateColor(config.defaultTextColor)
        }

        table.sort(points, thresholdComparer)

        -- tullaCTC's thresholds are end times, convert to start times
        for i = #points, 2, -1 do
            points[i].threshold = points[i - 1].threshold
        end
        points[1].threshold = 0
    else
        points[1] = {
            threshold = 0,
            color = Addon.CreateColor(config.defaultTextColor)
        }
    end

    return points
end

-- merge colorRGB and formatter breakpoints into breakpoint objects
-- precondition: both colors and formats need to be sorted by threshold values
local function createBreakpoints(colors, formats)
    local breakpoints = {}
    local i, j = 1, 1
    local state = {}

    while colors[i] or formats[j] do
        local c, f = colors[i], formats[j]
        local threshold

        if c and (not f or c.threshold <= f.threshold) then
            threshold = c.threshold

            state.color = c.color

            i = i + 1
        end

        if f and (not threshold or f.threshold <= threshold) then
            threshold = f.threshold

            state.step = f.step
            state.rounding = f.rounding
            state.min = f.min
            state.max = f.max
            state.format = f.format
            state.components = f.components

            j = j + 1
        end

        tinsert(breakpoints, {
            threshold = threshold,
            step = state.step,
            rounding = state.rounding,
            min = state.min,
            max = state.max,
            format = state.color and state.color:WrapTextInColorCode(state.format) or state.format,
            components = state.components
        })
    end

    return breakpoints
end

local function createFormatter(config)
    local colors = getColorBreakpoints(config)
    local formats = getFormatBreakpoints(config)
    local breakpoints = createBreakpoints(colors, formats)
    local formatter = C_StringUtil.CreateNumericRuleFormatter()

    formatter:SetBreakpoints(breakpoints)

    return formatter
end

-- themer functions are created to precompute the properties we want to set on
-- cooldowns to make things a tad bit more efficient
function Addon:CreateThemer(config)
    if not config.enabled then return NOOP end

    -- text settings
    local themeText = config.themeText
    local drawText = getDrawStateBool(config.drawText)
    local font, fontSize, fontFlags
    local point, offsetX, offsetY
    local shadowColor, shadowX, shadowY
    local formatter

    if themeText then
        if config.font then
            font = LibStub('LibSharedMedia-3.0'):Fetch('font', config.font) or STANDARD_TEXT_FONT
            fontSize = config.fontSize or 0
            fontFlags = config.fontFlags
        end

        point = config.point
        offsetX = config.offsetX
        offsetY = config.offsetY

        shadowColor = Addon.CreateColor(config.shadowColor)
        shadowX = config.shadowX
        shadowY = config.shadowY

        formatter = createFormatter(config)
    end

    -- cooldown settings
    local themeCooldown = config.themeCooldown
    local drawBling, drawEdge, drawSwipe, reverse
    local swipeColor

    if themeCooldown then
        drawBling = getDrawStateBool(config.drawBling)
        drawEdge = getDrawStateBool(config.drawEdge)
        drawSwipe = getDrawStateBool(config.drawSwipe)
        reverse = getDrawStateBool(config.reverse)

        if config.themeSwipeColor and config.swipeColor then
            swipeColor = Addon.CreateColor(config.swipeColor)
        end
    end

    return function(cooldown)
        if drawText ~= nil then
            cooldown:SetHideCountdownNumbers(not drawText)
        end

        if themeText then
            local text = cooldown:GetCountdownFontString()
            if font then
                if fontSize > 0 then
                    if not text:SetFont(font, fontSize, fontFlags) then
                        text:SetFont(STANDARD_TEXT_FONT, fontSize, fontFlags)
                    end
                else
                    cooldown:SetCountdownFont(font)
                end
            end

            if point then
                text:ClearAllPoints()
                text:SetPoint(point, offsetX, offsetY)
            end

            if shadowColor then
                text:SetShadowColor(shadowColor:GetRGBA())
                text:SetShadowOffset(shadowX, shadowY)
            end

            if formatter then
                cooldown:SetCountdownFormatter(formatter)
            end
        end

        if themeCooldown then
            if drawBling ~= nil then
                cooldown:SetDrawBling(drawBling)
            end

            if drawEdge ~= nil then
                cooldown:SetDrawEdge(drawEdge)
            end

            if drawSwipe ~= nil then
                cooldown:SetDrawSwipe(drawSwipe)
            end

            if reverse ~= nil then
                cooldown:SetReverse(reverse)
            end

            if swipeColor then
                cooldown:SetSwipeColor(swipeColor:GetRGBA())
            end
        end
    end
end
