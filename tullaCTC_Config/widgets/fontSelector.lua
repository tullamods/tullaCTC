local _, Addon = ...
local LSM = LibStub('LibSharedMedia-3.0')
local tullaCTC = _G.tullaCTC

function Addon:AddFontSelector(parent, themeID, property, opts)
    local row = self:CreateRow(parent, Addon.ROW_HEIGHT, opts)

    local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)
    dropdown:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    dropdown:SetHeight(Addon.DROPDOWN_HEIGHT)

    row:RegisterHighlightChild(dropdown)

    dropdown:SetupMenu(function(_, rootDescription)
        local fonts = LSM:List("font")
        table.sort(fonts)
        for _, name in ipairs(fonts) do
            rootDescription:CreateRadio(
                name,
                function() return tullaCTC.db.profile.themes[themeID][property] == name end,
                function() Addon:SetThemeProperty(themeID, property, name) end
            )
        end
    end)

    function row:Refresh(newID)
        themeID = newID
        dropdown:GenerateMenu()
    end

    return row
end
