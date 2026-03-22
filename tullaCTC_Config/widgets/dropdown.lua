local _, Addon = ...
local tullaCTC = _G.tullaCTC

local function attachStepper(row, themeIDRef, property, order, values)
    local stepper = CreateFrame("Frame", nil, row, "Metal2DropdownWithSteppersAndLabelTemplate")
    stepper.Label:Hide()
    stepper:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)
    stepper:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    stepper:SetHeight(Addon.DROPDOWN_HEIGHT)

    stepper.Dropdown:ClearAllPoints()
    stepper.Dropdown:SetPoint("LEFT", stepper, "LEFT", 31, 0)

    stepper.Dropdown:SetupMenu(function(_, rootDescription)
        for _, k in ipairs(order) do
            rootDescription:CreateRadio(values[k],
                function() return tullaCTC.db.profile.themes[themeIDRef()][property] == k end,
                function() Addon:SetThemeProperty(themeIDRef(), property, k) end)
        end
    end)

    local function step(delta)
        local current = tullaCTC.db.profile.themes[themeIDRef()][property]
        for i, k in ipairs(order) do
            if k == current then
                local next = order[i + delta]
                if next then
                    Addon:SetThemeProperty(themeIDRef(), property, next)
                    stepper.Dropdown:GenerateMenu()
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                end
                break
            end
        end
    end

    stepper.DecrementButton:SetScript("OnClick", function() step(-1) end)
    stepper.IncrementButton:SetScript("OnClick", function() step(1) end)

    stepper:EnableMouseWheel(true)
    stepper:SetScript("OnMouseWheel", function(_, delta)
        step(delta > 0 and 1 or -1)
    end)

    return stepper
end
Addon.attachStepper = attachStepper

function Addon:AddDropdown(parent, themeID, property, opts)
    local row = self:CreateRow(parent, Addon.ROW_HEIGHT, opts)

    local values = opts.values
    local order  = opts.order

    if order then
        local stepper = attachStepper(row, function() return themeID end, property, order, values)
        row:RegisterHighlightChild(stepper.Dropdown)
        row:RegisterHighlightChild(stepper.IncrementButton)
        row:RegisterHighlightChild(stepper.DecrementButton)

        function row:Refresh(newID)
            themeID = newID
            stepper.Dropdown:GenerateMenu()
        end
    else
        local dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("LEFT", row, "LEFT", Addon.LABEL_COL_WIDTH + Addon.PAD, 0)
        dropdown:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        dropdown:SetHeight(Addon.DROPDOWN_HEIGHT)

        row:RegisterHighlightChild(dropdown)

        dropdown:SetupMenu(function(_, rootDescription)
            for k, v in pairs(values) do
                rootDescription:CreateRadio(v,
                    function() return tullaCTC.db.profile.themes[themeID][property] == k end,
                    function() Addon:SetThemeProperty(themeID, property, k) end)
            end
        end)

        function row:Refresh(newID)
            themeID = newID
            dropdown:GenerateMenu()
        end
    end

    return row
end
