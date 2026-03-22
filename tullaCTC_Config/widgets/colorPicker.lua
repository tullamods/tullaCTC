local _, Addon = ...
local tullaCTC = _G.tullaCTC

function Addon:AddColorPicker(parent, themeID, property, opts)
    local default  = opts.default or "FFFFFFFF"
    local hasAlpha = opts.hasAlpha ~= false

    local row = self:CreateRow(parent, Addon.ROW_HEIGHT, opts)

    local swatchButton = CreateFrame("Button", nil, row)
    swatchButton:SetSize(26, 25)
    swatchButton:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)

    local bg = swatchButton:CreateTexture(nil, "BACKGROUND")
    bg:SetAtlas("common-dropdown-c-button", TextureKitConstants.UseAtlasSize)
    bg:SetPoint("CENTER")

    local colorTex = swatchButton:CreateTexture(nil, "ARTWORK")
    colorTex:SetPoint("TOPLEFT", 4, -3)
    colorTex:SetPoint("BOTTOMRIGHT", -4, 3)

    local function updateSwatch()
        local r, g, b, a = Addon.HexToRGBA(tullaCTC.db.profile.themes[themeID][property] or default)
        colorTex:SetColorTexture(r, g, b, a)
    end

    updateSwatch()

    swatchButton:SetScript("OnClick", function()
        local r, g, b, a = Addon.HexToRGBA(tullaCTC.db.profile.themes[themeID][property] or default)
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            opacity   = hasAlpha and (1 - a) or nil,
            hasOpacity = hasAlpha,
            swatchFunc = function()
                local r2, g2, b2 = ColorPickerFrame:GetColorRGB()
                local a2 = hasAlpha and (1 - ColorPickerFrame:GetColorAlpha()) or 1
                colorTex:SetColorTexture(r2, g2, b2, a2)
                Addon:SetThemeProperty(themeID, property, Addon.RGBAToHex(r2, g2, b2, a2))
            end,
            cancelFunc = function(prev)
                local pr, pg, pb = prev.r, prev.g, prev.b
                local pa = hasAlpha and (1 - (prev.opacity or 0)) or 1
                colorTex:SetColorTexture(pr, pg, pb, pa)
                Addon:SetThemeProperty(themeID, property, Addon.RGBAToHex(pr, pg, pb, pa))
            end,
        })
    end)

    row:RegisterHighlightChild(swatchButton)

    function row:Refresh(newID)
        themeID = newID
        updateSwatch()
    end

    function row:SetLabel(text)
        row.label:SetText(text)
    end

    return row
end
