-- Themer is a runtime object that styles cooldowns

local _, Addon = ...

local NOOP = {
    Apply = function() end,
    ApplyColor = function() end
}

-- converts draw state enum values into a bool|nil
local function getDrawStateBool(state)
    if state == "always" then
        return true
    elseif state == "never" then
        return false
    end
    return nil
end

local function generateColorCurve(textColors, defaultColor)
    table.sort(textColors, function(a, b)
        return (a.threshold or 0) < (b.threshold or 0)
    end)

    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)

    local offset = 0.5

    for i = 1, #textColors do
        local entry = textColors[i]
        local start = (i == 1 and 0) or (textColors[i - 1].threshold + offset)
        local color = Addon.CreateColor(entry.color)

        curve:AddPoint(start, color)
    end

    if defaultColor then
        local start = textColors[#textColors].threshold + offset
        local color = Addon.CreateColor(defaultColor)

        curve:AddPoint(start, color)
    end

    return curve
end

-- themer objects are created to precompute the properties we want to set on
-- cooldowns to make things a tad bit more efficient
function Addon:CreateThemer(config)
    if not config.enabled then
        return NOOP
    end

    -- text settings
    local themeText = config.themeText
    local drawText = getDrawStateBool(config.drawText)
    local useAuraDisplayTime
    local font, fontSize, fontFlags
    local point, offsetX, offsetY
    local shadowColor, shadowX, shadowY
    local abbrevThreshold, minDurationMS, textColors, defaultTextColor

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

        abbrevThreshold = config.abbrevThreshold
        minDurationMS = config.minDuration * 1000
        useAuraDisplayTime = getDrawStateBool(config.useAuraDisplayTime)

        if config.textColors and #config.textColors > 0 then
            textColors = generateColorCurve(config.textColors, config.defaultTextColor)
        end

        if config.defaultTextColor then
            defaultTextColor = Addon.CreateColor(config.defaultTextColor)
        end
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

    local themer = {}

    function themer:Apply(info)
        local cooldown = info.cooldown
        if drawText ~= nil then
            cooldown:SetHideCountdownNumbers(not drawText)
        end

        if themeText then
            local text = info.text
            if font then
                if fontSize > 0 then
                    if not text:SetFont(font, fontSize, fontFlags) then
                        text:SetFont(STANDARD_TEXT_FONT, fontSize, fontFlags)
                    end
                else
                    cooldown:SetCountdownFont(font)
                end
            end

            if textColors and info.duration then
                local color = info.duration:EvaluateRemainingDuration(textColors)
                text:SetTextColor(color:GetRGBA())
            elseif defaultTextColor then
                text:SetTextColor(defaultTextColor:GetRGBA())
            else
                text:SetTextColor(1, 1, 1, 1)
            end

            if point then
                text:ClearAllPoints()
                text:SetPoint(point, offsetX, offsetY)
            end

            if shadowColor then
                text:SetShadowColor(shadowColor:GetRGBA())
                text:SetShadowOffset(shadowX, shadowY)
            end

            if abbrevThreshold then
                cooldown:SetCountdownAbbrevThreshold(abbrevThreshold)
            end

            if minDurationMS then
                cooldown:SetMinimumCountdownDuration(minDurationMS)
            end

            if useAuraDisplayTime ~= nil then
                cooldown:SetUseAuraDisplayTime(useAuraDisplayTime)
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

    if themeText and textColors then
        function themer:ApplyColor(info)
            local duration = info.duration

            local color
            if duration then
                color = duration:EvaluateRemainingDuration(textColors)
            elseif defaultTextColor then
                color = defaultTextColor
            end

            if color then
                info.text:SetTextColor(color:GetRGBA())
            else
                info.text:SetTextColor(1, 1, 1, 1)
            end
        end
    else
        themer.ApplyColor = NOOP.ApplyColor
    end

    return themer
end
