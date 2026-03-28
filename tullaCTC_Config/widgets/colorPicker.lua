local _, Addon = ...

local function colorPicker_UpdateSwatch(self)
    local r, g, b, a = Addon.HexToRGBA(self.data[self.property] or self.default)
    self.ColorTexture:SetColorTexture(r, g, b, a)
end

local function colorPicker_SetLabel(self, text)
    self.Label:SetText(text)
end

--- Create a row with a color swatch that opens the color picker.
--- @param options table - inherits CreateRow fields
--- @field property string - data key for the hex color string
--- @field default? string - fallback hex color (default "FFFFFFFF")
--- @field hasAlpha? boolean - show alpha slider in color picker (default true)
function Addon:AddColorPicker(options)
    local property = options.property
    local default = options.default or "FFFFFFFF"

    local row = self:CreateRow(options)

    local swatch, colorTex = self:CreateSwatch(row)
    swatch:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)

    row.property = property
    row.default = default
    row.ColorTexture = colorTex

    row.Refresh = colorPicker_UpdateSwatch
    row.SetLabel = colorPicker_SetLabel

    colorPicker_UpdateSwatch(row)

    swatch:SetScript("OnClick", function()
        Addon:OpenColorPicker({
            color = row.data[row.property] or default,
            hasAlpha = options.hasAlpha,
            colorTex = colorTex,
            onChanged = function(hex)
                row:TriggerEvent("OnValueChanged", row.property, hex)
            end,
        })
    end)

    row:RegisterHighlightChild(swatch)

    return row
end
