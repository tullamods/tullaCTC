-- Themer is a runtime object that styles cooldowns

local _, Addon = ...

local NOOP = {
    Apply = function() end,
    UpdateColor = function() end
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

local function generateColorCurve(colorThresholds)
    if not (colorThresholds and #colorThresholds > 0) then
        return
    end

    table.sort(colorThresholds, function(a, b)
        return a.threshold < b.threshold
    end)

    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)

    for i, entry in ipairs(colorThresholds) do
        local startTime = (i > 1 and colorThresholds[i - 1].threshold or -1) + 0.5
        local color = CreateColorFromRGBAHexString(entry.color)

        curve:AddPoint(startTime, color)
    end

    return curve
end

-- themer objects are created to precompute of the properties we want to set on
-- cooldowns to make things a tad bit more efficient
function Addon.CreateThemer(config)
    if not config.enabled then
        return NOOP
    end

    -- text settings
    local themeText = config.themeText
    local drawText = getDrawStateBool(config.drawText)
    local font, fontSize, fontFlags
    local point, offsetX, offsetY
    local shadowColor, shadowX, shadowY
    local abbrevThreshold, minDurationMS, textColors

    if themeText then
        if config.font then
            font = LibStub('LibSharedMedia-3.0'):Fetch('font', config.font) or STANDARD_TEXT_FONT
            fontSize = config.fontSize or 0
            fontFlags = config.fontFlags
        end

        point = config.point
        offsetX = config.offsetX
        offsetY = config.offsetY

        shadowColor = CreateColorFromRGBAHexString(config.shadowColor)
        shadowX = config.shadowX
        shadowY = config.shadowY

        abbrevThreshold = config.abbrevThreshold
        minDurationMS = config.minDuration * 1000

        textColors = generateColorCurve(config.textColors)
    end

    -- cooldown settings
    local themeCooldown = config.themeCooldown
    local drawBling, drawEdge, drawSwipe, reverse

    if themeCooldown then
        drawBling = getDrawStateBool(config.drawBling)
        drawEdge = getDrawStateBool(config.drawEdge)
        drawSwipe = getDrawStateBool(config.drawSwipe)
        reverse = getDrawStateBool(config.reverse)
    end

    local themer = {}

    function themer:Apply(cdInfo)
        local cooldown = cdInfo.cooldown

        if drawText ~= nil then
            cooldown:SetHideCountdownNumbers(not drawText)
        end

        if themeText then
            local text = cooldown:GetCountdownFontString()
            if text then
                if font then
                    if fontSize > 0 then
                        if not text:SetFont(font, fontSize, fontFlags) then
                            text:SetFont(STANDARD_TEXT_FONT, fontSize, fontFlags)
                        end
                    else
                        cooldown:SetCountdownFont(font)
                    end
                end

                if textColors and cdInfo.duration then
                    text:SetTextColor(cdInfo.duration:EvaluateRemainingDuration(textColors):GetRGBA())
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
            end

            if abbrevThreshold then
                cooldown:SetCountdownAbbrevThreshold(abbrevThreshold)
            end

            if minDurationMS then
                cooldown:SetMinimumCountdownDuration(minDurationMS)
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

            -- TODO: consider the other mutable properties of cooldowns
            -- like swipe, bling, and edge textures
        end
    end

    if themeText and textColors then
        function themer:UpdateColor(cdInfo)
            local text = cdInfo.cooldown:GetCountdownFontString()
            if not text then
                return
            end

            local duration = cdInfo.duration
            local r, g, b, a

            if duration then
                r, g, b, a = duration:EvaluateRemainingDuration(textColors):GetRGBA()
            else
                r, g, b, a = 1, 1, 1, 1
            end

            text:SetTextColor(r, g, b, a)
        end
    else
        themer.UpdateColor = NOOP.UpdateColor
    end

    return themer
end
