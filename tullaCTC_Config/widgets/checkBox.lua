local _, Addon = ...

local function checkBox_Refresh(self)
    self.CheckBox:SetChecked(self.data[self.property])
end

local function checkBox_OnClick(self)
    local row = self:GetParent()
    row:TriggerEvent("OnValueChanged", row.property, self:GetChecked())
end

--- Create a section header with an embedded checkbox.
--- @param options table - inherits CreateRow fields
--- @field property string - data key for the boolean value
function Addon:AddSectionCheckBox(options)
    local h = CreateFrame("Frame", nil, options.parent, "SettingsListSectionHeaderTemplate")
    Mixin(h, CallbackRegistryMixin)
    CallbackRegistryMixin.OnLoad(h)
    h:GenerateCallbackEvents(Addon.ROW_EVENTS)
    h.Refresh = checkBox_Refresh

    h:SetHeight(45)
    h.Title:SetText(options.name)

    local cb = CreateFrame("CheckButton", nil, h, "MinimalCheckboxTemplate")
    cb:SetPoint("LEFT", h, "LEFT", 0, 0)
    h.Title:ClearAllPoints()
    h.Title:SetPoint("LEFT", cb, "RIGHT", Addon.PADDING, 0)
    cb:SetChecked(options.data[options.property])

    h.data = options.data
    h.property = options.property
    h.CheckBox = cb

    cb:SetScript("OnClick", checkBox_OnClick)

    return h
end

--- Create a row with a checkbox control.
--- @param options table - inherits CreateRow fields
--- @field property string - data key for the boolean value
function Addon:AddCheckBox(options)
    local row = self:CreateRow(options)

    row.property = options.property

    local cb = CreateFrame("CheckButton", nil, row, "MinimalCheckboxTemplate")
    cb:SetPoint("LEFT", row, "LEFT", Addon.LABEL_WIDTH + Addon.PADDING, 0)
    cb:SetChecked(row.data[row.property])

    row:RegisterHighlightChild(cb)

    row.CheckBox = cb

    row.Refresh = checkBox_Refresh

    cb:SetScript("OnClick", checkBox_OnClick)

    return row
end
