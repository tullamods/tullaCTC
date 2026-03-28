local _, Addon = ...

local function checkBoxColorPicker_UpdateSwatch(self)
    local r, g, b, a = Addon.HexToRGBA(self.data[self.colorProperty] or self.default)
    self.ColorTexture:SetColorTexture(r, g, b, a)
end

local function checkBoxColorPicker_Refresh(self)
    self.CheckBox:SetChecked(self.data[self.checkProperty])
    checkBoxColorPicker_UpdateSwatch(self)
end

--- Create a row with a checkbox and a color swatch.
--- @param options table - inherits CreateRow fields
--- @field checkProperty string - data key for the boolean value
--- @field colorProperty string - data key for the hex color string
--- @field default? string - fallback hex color (default "FFFFFFFF")
--- @field hasAlpha? boolean - show alpha slider in color picker (default true)
function Addon:AddCheckBoxColorPicker(options)
    local checkProperty = options.checkProperty
    local colorProperty = options.colorProperty
    local default = options.default or "FFFFFFFF"

    local row = self:CreateRow(options)

    local cb = CreateFrame("CheckButton", nil, row, "MinimalCheckboxTemplate")
    cb:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)
    cb:SetChecked(row.data[checkProperty])

    local swatch, colorTex = self:CreateSwatch(row)
    swatch:SetPoint("LEFT", cb, "RIGHT", Addon.PADDING, 0)

    row.checkProperty = checkProperty
    row.colorProperty = colorProperty
    row.default = default
    row.CheckBox = cb
    row.ColorTexture = colorTex

    row.Refresh = checkBoxColorPicker_Refresh

    checkBoxColorPicker_UpdateSwatch(row)

    swatch:SetScript("OnClick", function()
        Addon:OpenColorPicker({
            color = row.data[row.colorProperty] or default,
            hasAlpha = options.hasAlpha,
            colorTex = colorTex,
            onChanged = function(hex)
                row:TriggerEvent("OnValueChanged", row.colorProperty, hex)
            end,
        })
    end)

    row:RegisterHighlightChild(cb)
    row:RegisterHighlightChild(swatch)

    cb:SetScript("OnClick", function()
        row:TriggerEvent("OnValueChanged", row.checkProperty, cb:GetChecked())
    end)

    return row
end
