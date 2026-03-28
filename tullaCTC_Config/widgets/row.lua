local _, Addon = ...

local ROW_HEIGHT = 26

local RowHighlightMixin = {}

function RowHighlightMixin:OnLoad()
    self:EnableMouse(true)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)

    local bg = self:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.06)
    bg:Hide()

    self.HoverBackground = bg
end

function RowHighlightMixin:OnEnter()
    self.HoverBackground:Show()

    if self.TooltipTitle then
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(self.TooltipTitle, 1, 0.82, 0)
        if self.TooltipText then
            GameTooltip:AddLine(self.TooltipText, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end
end

function RowHighlightMixin:OnLeave()
    if not self:IsMouseOver() then
        self.HoverBackground:Hide()
        GameTooltip:Hide()
    end
end

function RowHighlightMixin:RegisterHighlightChild(child)
    local row = self

    child:HookScript("OnEnter", function() row:OnEnter() end)
    child:HookScript("OnLeave", function() row:OnLeave() end)
end

local ROW_EVENTS = { "OnValueChanged" }
Addon.ROW_EVENTS = ROW_EVENTS

--- Create a base row frame with label, tooltip, and callback support.
--- @param options table
--- @field parent Frame - parent frame
--- @field data table - data source for the row
--- @field name? string - label text
--- @field desc? string - tooltip description (enables hover highlight)
function Addon:CreateRow(options)
    local row = CreateFrame("Frame", nil, options.parent)

    Mixin(row, CallbackRegistryMixin, RowHighlightMixin)
    CallbackRegistryMixin.OnLoad(row)
    row:GenerateCallbackEvents(ROW_EVENTS)

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", row, "LEFT", 0, 0)
    label:SetWidth(Addon.LABEL_WIDTH)
    label:SetJustifyH("LEFT")
    row.Label = label

    if options.name then label:SetText(options.name) end
    if options.desc then
        row.TooltipTitle = options.name
        row.TooltipText = options.desc
    end

    row.data = options.data

    row:SetHeight(ROW_HEIGHT)
    RowHighlightMixin.OnLoad(row)

    return row
end
