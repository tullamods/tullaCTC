local _, Addon = ...
local tullaCTC = _G.tullaCTC

function Addon:AddCheckBoxColorPicker(parent, themeID, checkProperty, colorProperty, opts)
    local default  = opts.default or "FFFFFFFF"
    local hasAlpha = opts.hasAlpha ~= false

    local row = self:CreateRow(parent, Addon.ROW_HEIGHT, opts)

    local cb = CreateFrame("CheckButton", nil, row, "SettingsCheckboxTemplate")
    cb:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)
    cb:Init(tullaCTC.db.profile.themes[themeID][checkProperty])
    if cb.HoverBackground then cb.HoverBackground:Hide() end

    local swatchButton = CreateFrame("Button", nil, row)
    swatchButton:SetSize(26, 25)
    swatchButton:SetPoint("LEFT", cb, "RIGHT", Addon.PAD, 0)

    local bg = swatchButton:CreateTexture(nil, "BACKGROUND")
    bg:SetAtlas("common-dropdown-c-button", TextureKitConstants.UseAtlasSize)
    bg:SetPoint("CENTER")

    local colorTex = swatchButton:CreateTexture(nil, "ARTWORK")
    colorTex:SetPoint("TOPLEFT", 4, -3)
    colorTex:SetPoint("BOTTOMRIGHT", -4, 3)

    local function updateSwatch()
        local r, g, b, a = Addon.HexToRGBA(tullaCTC.db.profile.themes[themeID][colorProperty] or default)
        colorTex:SetColorTexture(r, g, b, a)
    end

    updateSwatch()

    swatchButton:SetScript("OnClick", function()
        local r, g, b, a = Addon.HexToRGBA(tullaCTC.db.profile.themes[themeID][colorProperty] or default)
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
                Addon:SetThemeProperty(themeID, colorProperty, Addon.RGBAToHex(r2, g2, b2, a2))
            end,
            cancelFunc = function(prev)
                local pr, pg, pb = prev.r, prev.g, prev.b
                local pa = hasAlpha and (1 - (prev.opacity or 0)) or 1
                colorTex:SetColorTexture(pr, pg, pb, pa)
                Addon:SetThemeProperty(themeID, colorProperty, Addon.RGBAToHex(pr, pg, pb, pa))
            end,
        })
    end)

    row:RegisterHighlightChild(cb)
    row:RegisterHighlightChild(swatchButton)

    local updating = false
    cb:RegisterCallback(SettingsCheckboxMixin.Event.OnValueChanged, function(_, checked)
        if not updating then
            Addon:SetThemeProperty(themeID, checkProperty, checked)
        end
    end)

    function row:Refresh(newID)
        themeID = newID
        updating = true
        cb:Init(tullaCTC.db.profile.themes[themeID][checkProperty])
        updating = false
        updateSwatch()
    end

    return row
end
