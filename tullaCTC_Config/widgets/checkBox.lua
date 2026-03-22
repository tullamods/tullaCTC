local _, Addon = ...
local tullaCTC = _G.tullaCTC

function Addon:AddCheckBox(parent, themeID, property, opts)
    local row = self:CreateRow(parent, Addon.ROW_HEIGHT, opts)

    local cb = CreateFrame("CheckButton", nil, row, "SettingsCheckboxTemplate")
    cb:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)
    cb:Init(tullaCTC.db.profile.themes[themeID][property])
    if cb.HoverBackground then cb.HoverBackground:Hide() end

    row:RegisterHighlightChild(cb)

    local updating = false
    cb:RegisterCallback(SettingsCheckboxMixin.Event.OnValueChanged, function(_, checked)
        if not updating then
            Addon:SetThemeProperty(themeID, property, checked)
        end
    end)

    function row:Refresh(newID)
        themeID = newID
        updating = true
        cb:Init(tullaCTC.db.profile.themes[themeID][property])
        updating = false
    end

    return row
end
