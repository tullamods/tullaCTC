local _, Addon = ...

local COLOR_ROW_POOL_SIZE = 12

local function updateColorRow(row, entry, rowIndex, themeID, prevThreshold)
    row.themeID = themeID
    row.colorIndex = rowIndex
    row.color = entry.color
    row.Label:SetText(Addon:FormatColorRange(prevThreshold, entry.threshold))
    local r, g, b, a = Addon.HexToRGBA(entry.color)
    row.ColorTexture:SetColorTexture(r, g, b, a)
end
Addon.UpdateColorRow = updateColorRow

function Addon:BuildColorRowPool(parent)
    local pool = {}
    for i = 1, COLOR_ROW_POOL_SIZE do
        local row = self:CreateRow({ parent = parent })
        row:Hide()

        row.themeID = nil
        row.colorIndex = nil
        row.color = nil

        local swatch, colorTex = self:CreateSwatch(row)
        swatch:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)
        row.ColorTexture = colorTex

        local removeBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        removeBtn:SetSize(24, 24)
        removeBtn:SetPoint("RIGHT", row, "RIGHT", -16, 0)
        removeBtn:Hide()

        row:RegisterHighlightChild(swatch)
        row:RegisterHighlightChild(removeBtn)

        local function showRemove() removeBtn:Show() end
        local function hideRemove()
            if not row:IsMouseOver() then
                removeBtn:Hide()
            end
        end

        row:HookScript("OnEnter", showRemove)
        row:HookScript("OnLeave", hideRemove)
        swatch:HookScript("OnEnter", showRemove)
        swatch:HookScript("OnLeave", hideRemove)
        removeBtn:HookScript("OnLeave", hideRemove)

        swatch:SetScript("OnClick", function()
            Addon:OpenColorPicker({
                color = row.color or "FFFFFFFF",
                colorTex = colorTex,
                onChanged = function(hex)
                    Addon:SetTextColorValue(row.themeID, row.colorIndex, hex)
                end,
            })
        end)

        removeBtn:SetScript("OnClick", function()
            Addon:RemoveTextColorEntry(row.themeID, row.colorIndex)
        end)

        pool[i] = row
    end
    return pool
end
