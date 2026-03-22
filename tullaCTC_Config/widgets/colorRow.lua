local _, Addon = ...

local COLOR_ROW_POOL_SIZE = 12

function Addon:BuildColorRowPool(parent)
    local pool = {}
    for i = 1, COLOR_ROW_POOL_SIZE do
        local row = self:CreateRow(parent, Addon.ROW_HEIGHT)
        row:Hide()

        local swatch = CreateFrame("Button", nil, row)
        swatch:SetSize(26, 25)
        swatch:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)

        local swBg = swatch:CreateTexture(nil, "BACKGROUND")
        swBg:SetAtlas("common-dropdown-c-button", TextureKitConstants.UseAtlasSize)
        swBg:SetPoint("CENTER")

        local colorTex = swatch:CreateTexture(nil, "ARTWORK")
        colorTex:SetPoint("TOPLEFT", swatch, "TOPLEFT", 4, -3)
        colorTex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -4, 3)

        local removeBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        removeBtn:SetSize(24, 24)
        removeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

        row:RegisterHighlightChild(swatch)
        row:RegisterHighlightChild(removeBtn)

        function row:Update(entry, rowIndex, theme, prevThreshold)
            row.label:SetText(Addon:FormatColorRange(prevThreshold, entry.threshold))
            local r, g, b, a = Addon.HexToRGBA(entry.color)
            colorTex:SetColorTexture(r, g, b, a)

            swatch:SetScript("OnClick", function()
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r, g = g, b = b,
                    opacity = 1 - a,
                    hasOpacity = true,
                    swatchFunc = function()
                        local r2, g2, b2 = ColorPickerFrame:GetColorRGB()
                        local a2 = 1 - ColorPickerFrame:GetColorAlpha()
                        colorTex:SetColorTexture(r2, g2, b2, a2)
                        Addon:SetTextColorValue(theme, rowIndex, Addon.RGBAToHex(r2, g2, b2, a2))
                    end,
                    cancelFunc = function(prev)
                        local pr, pg, pb = prev.r, prev.g, prev.b
                        local pa = 1 - (prev.opacity or 0)
                        colorTex:SetColorTexture(pr, pg, pb, pa)
                        Addon:SetTextColorValue(theme, rowIndex, Addon.RGBAToHex(pr, pg, pb, pa))
                    end,
                })
            end)

            removeBtn:SetScript("OnClick", function()
                if Addon:RemoveTextColorEntry(theme, rowIndex) then
                    Addon:RefreshThemeTree()
                end
            end)
        end

        pool[i] = row
    end
    return pool
end
