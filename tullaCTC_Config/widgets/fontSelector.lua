local _, Addon = ...
local LSM = LibStub('LibSharedMedia-3.0')

local cachedFonts = nil

LSM.RegisterCallback(Addon, "LibSharedMedia_Registered", function(_, mediatype)
    if mediatype == "font" then
        cachedFonts = nil
    end
end)

local function getSortedFonts()
    if not cachedFonts then
        cachedFonts = CopyTable(LSM:List("font"))
        table.sort(cachedFonts)
    end
    return cachedFonts
end

local function fontSelector_Refresh(self)
    self.Dropdown:GenerateMenu()
end

--- Create a row with a font dropdown populated from LibSharedMedia.
--- @param options table - inherits CreateRow fields
--- @field property string - data key for the font name
function Addon:AddFontSelector(options)
    local property = options.property

    local row = self:CreateRow(options)

    local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle2DropdownTemplate")
    dropdown:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)
    dropdown:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    dropdown:SetHeight(Addon.DROPDOWN_HEIGHT)

    row:RegisterHighlightChild(dropdown)

    row.property = property
    row.Dropdown = dropdown

    row.Refresh = fontSelector_Refresh

    dropdown:SetupMenu(function(_, rootDescription)
        for _, name in ipairs(getSortedFonts()) do
            rootDescription:CreateRadio(
                name,
                function() return row.data[property] == name end,
                function() row:TriggerEvent("OnValueChanged", property, name) end
            )
        end
    end)

    return row
end
