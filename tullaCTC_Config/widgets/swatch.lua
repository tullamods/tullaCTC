local _, Addon = ...

function Addon:CreateSwatch(parent)
    local swatch = CreateFrame("Button", nil, parent)
    swatch:SetSize(26, 25)

    local bg = swatch:CreateTexture(nil, "BACKGROUND")
    bg:SetAtlas("common-dropdown-c-button", TextureKitConstants.UseAtlasSize)
    bg:SetPoint("CENTER")

    local colorTex = swatch:CreateTexture(nil, "ARTWORK")
    colorTex:SetPoint("TOPLEFT", 4, -3)
    colorTex:SetPoint("BOTTOMRIGHT", -4, 3)

    return swatch, colorTex
end

function Addon:OpenColorPicker(opts)
    local r, g, b, a = Addon.HexToRGBA(opts.color or "FFFFFFFF")
    local hasAlpha = opts.hasAlpha ~= false

    ColorPickerFrame:SetupColorPickerAndShow({
        r = r, g = g, b = b,
        opacity = hasAlpha and (1 - a) or nil,
        hasOpacity = hasAlpha,
        swatchFunc = function()
            local r2, g2, b2 = ColorPickerFrame:GetColorRGB()
            local a2 = hasAlpha and (1 - ColorPickerFrame:GetColorAlpha()) or 1
            opts.colorTex:SetColorTexture(r2, g2, b2, a2)
            opts.onChanged(Addon.RGBAToHex(r2, g2, b2, a2))
        end,
        cancelFunc = function(prev)
            local pr, pg, pb = prev.r, prev.g, prev.b
            local pa = hasAlpha and (1 - (prev.opacity or 0)) or 1
            opts.colorTex:SetColorTexture(pr, pg, pb, pa)
            opts.onChanged(Addon.RGBAToHex(pr, pg, pb, pa))
        end,
    })
end
