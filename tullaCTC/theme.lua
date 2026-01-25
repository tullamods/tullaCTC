-- Theme is a runtime object for applying cooldown settings

local _, Addon = ...

--- @alias Duration table A duration object from C_DurationUtil
--- @alias ColorCurve table A color curve from C_CurveUtil

--- Data object passed to theme methods
--- @class CooldownData
--- @field cooldown Cooldown The cooldown frame
--- @field duration Duration A duration object from C_DurationUtil
--- @field theme Theme The theme applied to this cooldown
--- @field fontString FontString The countdown font string

--- Theme object for styling cooldown text
--- @class Theme
--- @field fontName string Font file path
--- @field fontSize number Font size in points
--- @field fontFlags string Font flags (e.g., "OUTLINE")
--- @field point string Anchor point (e.g., "CENTER")
--- @field offsetX number Horizontal offset from anchor
--- @field offsetY number Vertical offset from anchor
--- @field shadowX number Shadow horizontal offset
--- @field shadowY number Shadow vertical offset
--- @field abbrevThreshold number Duration threshold for abbreviated text (ms)
--- @field minDuration number Minimum duration to show countdown (ms)
--- @field shadowColor table Precomputed shadow color
--- @field colorCurve ColorCurve Optional color curve for time-based coloring

local function generateColorCurve(colorData)
    local thresholds = {}
    for threshold in pairs(colorData) do
        thresholds[#thresholds+1] = threshold
    end
    table.sort(thresholds)

    local colorCurve = C_CurveUtil.CreateColorCurve()
    colorCurve:SetType(Enum.LuaCurveType.Step)

    for i, threshold in ipairs(thresholds) do
        local startTime = i > 1 and thresholds[i - 1] or 0
        local color = CreateColorFromRGBAHexString(colorData[threshold])
        colorCurve:AddPoint(startTime, color)
    end

    return colorCurve
end

--- Creates a new theme from settings
--- @param config table Theme settings from saved variables
--- @return Theme
function Addon.CreateTheme(config)
    local font = LibStub('LibSharedMedia-3.0'):Fetch('font', config.font)
    local fontSize = config.fontSize
    local fontFlags = config.fontFlags
    local point = config.point
    local offsetX = config.offsetX
    local offsetY = config.offsetY
    local shadowX = config.shadowX
    local shadowY = config.shadowY
    local abbrevThreshold = config.abbrevThreshold
    local forceShowText = config.forceShowText

    -- min duration actually needs to be specified in miliseconds, not seconds
    local minDurationMS = config.minDuration * 1000
    local shadowColor = CreateColorFromRGBAHexString(config.shadowColor)
    local colorCurve = generateColorCurve(config.curves.color)

    local theme = {}

    --- Applies theme styling to a cooldown's font string
    --- @param cooldownInfo CooldownData
    function theme:Apply(cooldownInfo)
        if not cooldownInfo.fontString:SetFont(font, fontSize, fontFlags) then
            cooldownInfo.fontString:SetFont(STANDARD_TEXT_FONT, fontSize, fontFlags)
        end

        if forceShowText then
            cooldownInfo.cooldown:SetHideCountdownNumbers(false)
        end

        cooldownInfo.fontString:ClearAllPoints()
        cooldownInfo.fontString:SetPoint(point, offsetX, offsetY)
        cooldownInfo.fontString:SetShadowColor(shadowColor:GetRGBA())
        cooldownInfo.fontString:SetShadowOffset(shadowX, shadowY)

        cooldownInfo.cooldown:SetCountdownAbbrevThreshold(abbrevThreshold)
        cooldownInfo.cooldown:SetMinimumCountdownDuration(minDurationMS)

        local color = cooldownInfo.duration:EvaluateRemainingDuration(colorCurve)
        cooldownInfo.fontString:SetTextColor(color:GetRGBA())
    end

    --- Updates the font string color based on remaining duration
    --- @param cooldownInfo CooldownData
    function theme:UpdateColor(cooldownInfo)
        local color = cooldownInfo.duration:EvaluateRemainingDuration(colorCurve)
        cooldownInfo.fontString:SetTextColor(color:GetRGBA())
    end

    return theme
end
