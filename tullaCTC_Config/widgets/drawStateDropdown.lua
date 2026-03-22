local _, Addon    = ...

local L           = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)

local DRAW_ORDER  = { "default", "always", "never" }

local DRAW_VALUES = {
    default = L.DrawState_default,
    always  = L.DrawState_always,
    never   = L.DrawState_never,
}

function Addon:AddDrawStateDropdown(parent, themeID, property, opts)
    local row = self:CreateRow(parent, Addon.ROW_HEIGHT, opts)

    local stepper = Addon.attachStepper(row, function() return themeID end, property, DRAW_ORDER, DRAW_VALUES)
    row:RegisterHighlightChild(stepper.Dropdown)
    row:RegisterHighlightChild(stepper.IncrementButton)
    row:RegisterHighlightChild(stepper.DecrementButton)

    function row:Refresh(newID)
        themeID = newID
        stepper.Dropdown:GenerateMenu()
    end

    return row
end
