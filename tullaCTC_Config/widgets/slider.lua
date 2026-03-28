local _, Addon = ...

local SLIDER_HEIGHT = 40

local function slider_UpdateLabel(self, value)
    self.ValueLabel:SetText(tostring(Round(self.invert and -value or value)))
end

local function slider_Refresh(self)
    local v = self.data[self.property] or self.default
    local slider = self.Slider

    slider:SetScript("OnValueChanged", nil)
    slider:SetValue(self.invert and -v or v)
    slider:SetScript("OnValueChanged", self.SliderOnValueChanged)

    slider_UpdateLabel(self, self.invert and -v or v)
end

--- Create a row with a slider, stepper buttons, and value label.
--- @param options table - inherits CreateRow fields
--- @field property string - data key for the numeric value
--- @field min? number - minimum value (default 0)
--- @field max? number - maximum value (default 100)
--- @field default? number - fallback value (default 0)
--- @field invert? boolean - negate the displayed/stored value
function Addon:AddSlider(options)
    local row = self:CreateRow(options)
    row:SetHeight(SLIDER_HEIGHT)

    local property = options.property
    local invert = options.invert
    local default = options.default or 0
    local val = row.data[property] or default
    local sliderMin = options.min or 0
    local sliderMax = options.max or 100
    local steps = math.max(1, sliderMax - sliderMin)
    local step = (sliderMax - sliderMin) / steps

    local slider = CreateFrame("Slider", nil, row, "MinimalSliderTemplate")
    slider:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING + 19, 0)
    slider:SetPoint("RIGHT", row, "RIGHT", -50, 0)
    slider:SetMinMaxValues(sliderMin, sliderMax)
    slider:SetValueStep(step)
    slider:SetValue(invert and -val or val)

    local back = CreateFrame("Button", nil, row)
    back:SetSize(11, 19)
    back:SetPoint("RIGHT", slider, "LEFT", -4, 0)
    back:SetNormalAtlas("Minimal_SliderBar_Button_Left")

    local forward = CreateFrame("Button", nil, row)
    forward:SetSize(9, 18)
    forward:SetPoint("LEFT", slider, "RIGHT", 4, 0)
    forward:SetNormalAtlas("Minimal_SliderBar_Button_Right")

    local valueLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    valueLabel:SetPoint("LEFT", forward, "RIGHT", 4, 0)

    row.property = property
    row.Slider = slider
    row.invert = invert
    row.default = default
    row.ValueLabel = valueLabel

    row.Refresh = slider_Refresh
    row.UpdateLabel = slider_UpdateLabel
    slider_UpdateLabel(row, invert and -val or val)

    local function onValueChanged(_, newVal)
        row:UpdateLabel(newVal)
        row:TriggerEvent("OnValueChanged", property, invert and -newVal or newVal)
    end
    row.SliderOnValueChanged = onValueChanged
    slider:SetScript("OnValueChanged", onValueChanged)

    back:SetScript("OnClick", function()
        slider:SetValue(slider:GetValue() - slider:GetValueStep())
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

    forward:SetScript("OnClick", function()
        slider:SetValue(slider:GetValue() + slider:GetValueStep())
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

    row:EnableMouseWheel(true)
    row:SetScript("OnMouseWheel", function(_, delta)
        slider:SetValue(slider:GetValue() + delta * slider:GetValueStep())
    end)

    row:RegisterHighlightChild(slider)
    row:RegisterHighlightChild(back)
    row:RegisterHighlightChild(forward)

    return row
end
