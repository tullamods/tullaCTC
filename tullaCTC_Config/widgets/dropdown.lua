local _, Addon = ...

local function dropdown_Refresh(self)
    self.Dropdown:GenerateMenu()
end

--- Create a row with a dropdown control. Includes stepper buttons when order is provided.
--- @param options table - inherits CreateRow fields
--- @field property string - data key for the selected value
--- @field values table<any, string> - map of value keys to display names
--- @field order? any[] - ordered keys; enables stepper arrows and mousewheel
function Addon:AddDropdown(options)
    local property = options.property
    local values = options.values
    local order = options.order

    local row = self:CreateRow(options)

    row.property = property

    if order then
        local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle2DropdownTemplate")
        dropdown:SetHeight(Addon.DROPDOWN_HEIGHT)

        local backBtn = CreateFrame("Button", nil, row, "WowStyle2IconButtonTemplate")
        backBtn.normalAtlas = "common-dropdown-icon-back"
        backBtn.disabledAtlas = "common-dropdown-icon-back-disabled"
        backBtn:OnLoad()
        backBtn:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)

        dropdown:SetPoint("LEFT", backBtn, "RIGHT", 4, 0)
        dropdown:SetWidth(244)

        local forwardBtn = CreateFrame("Button", nil, row, "WowStyle2IconButtonTemplate")
        forwardBtn.normalAtlas = "common-dropdown-icon-next"
        forwardBtn.disabledAtlas = "common-dropdown-icon-next-disabled"
        forwardBtn:OnLoad()
        forwardBtn:SetPoint("LEFT", dropdown, "RIGHT", 4, 0)

        dropdown:SetupMenu(function(_, rootDescription)
            for _, k in ipairs(order) do
                rootDescription:CreateRadio(values[k],
                    function() return row.data[property] == k end,
                    function() row:TriggerEvent("OnValueChanged", property, k) end)
            end
        end)

        local function step(delta)
            local current = row.data[property]
            for i, k in ipairs(order) do
                if k == current then
                    local nextKey = order[i + delta]
                    if nextKey then
                        row:TriggerEvent("OnValueChanged", property, nextKey)
                        dropdown:GenerateMenu()
                        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                    end
                    break
                end
            end
        end

        backBtn:SetScript("OnClick", function() step(-1) end)
        forwardBtn:SetScript("OnClick", function() step(1) end)

        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta)
            step(delta > 0 and 1 or -1)
        end)

        row:RegisterHighlightChild(dropdown)
        row:RegisterHighlightChild(backBtn)
        row:RegisterHighlightChild(forwardBtn)

        row.Dropdown = dropdown
        row.Refresh = dropdown_Refresh
    else
        local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)
        dropdown:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        dropdown:SetHeight(Addon.DROPDOWN_HEIGHT)

        row:RegisterHighlightChild(dropdown)

        dropdown:SetupMenu(function(_, rootDescription)
            for k, v in pairs(values) do
                rootDescription:CreateRadio(v,
                    function() return row.data[property] == k end,
                    function() row:TriggerEvent("OnValueChanged", property, k) end)
            end
        end)

        row.Dropdown = dropdown
        row.Refresh = dropdown_Refresh
    end

    return row
end
