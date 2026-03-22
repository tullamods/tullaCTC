local _, Addon = ...
local tullaCTC = _G.tullaCTC

function Addon:AddSlider(parent, themeID, property, opts)
    local row = self:CreateRow(parent, Addon.SLIDER_HEIGHT, opts)

    local slider = CreateFrame("Frame", nil, row, "MinimalSliderWithSteppersTemplate")
    slider:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)
    slider:SetPoint("RIGHT", row, "RIGHT", -20, 0)
    slider:SetHeight(Addon.SLIDER_HEIGHT)

    local invert = opts.invert
    local default = opts.default or 0
    local val = tullaCTC.db.profile.themes[themeID][property] or default
    local sliderMin = opts.min or 0
    local sliderMax = opts.max or 100
    local steps = math.max(1, sliderMax - sliderMin)

    local formatters = {
        [MinimalSliderWithSteppersMixin.Label.Right] = function(v)
            return tostring(Round(invert and -v or v))
        end,
    }
    slider:Init(invert and -val or val, sliderMin, sliderMax, steps, formatters)

    row:RegisterHighlightChild(slider)
    for _, child in ipairs({slider:GetChildren()}) do
        row:RegisterHighlightChild(child)
    end

    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(_, delta)
        local s = slider.Slider
        s:SetValue(s:GetValue() + delta * s:GetValueStep())
    end)

    local updating = false
    slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, newVal)
        if not updating then
            Addon:SetThemeProperty(themeID, property, invert and -newVal or newVal)
        end
    end)

    function row:Refresh(newID)
        themeID = newID
        local v = tullaCTC.db.profile.themes[themeID][property] or default
        updating = true
        slider:Init(invert and -v or v, sliderMin, sliderMax, steps, formatters)
        updating = false
    end

    return row
end
