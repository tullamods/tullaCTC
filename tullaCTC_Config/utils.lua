local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

Addon.HexToRGBA = tullaCTC.HexToRGBA
Addon.RGBAToHex = tullaCTC.RGBAToHex

function Addon.GetThemeDisplayName(id)
    local theme = tullaCTC.db.profile.themes[id]
    if theme then
        return theme.displayName or rawget(L, 'Theme_' .. id) or id
    end
    return id
end

local PAD = 8
local SPACING = 6
local SECTION_TITLE_HEIGHT = 18
local LABEL_COL_WIDTH = 200

Addon.PAD = PAD
Addon.SPACING = SPACING
Addon.ROW_HEIGHT = 26
Addon.SLIDER_HEIGHT = 40
Addon.DROPDOWN_HEIGHT = 25
Addon.LABEL_COL_WIDTH = LABEL_COL_WIDTH

function Addon:FormatDuration(seconds)
    if seconds >= 86400 then
        return L.ColorRangeDays:format(Round(seconds / 86400))
    elseif seconds >= 3600 then
        return L.ColorRangeHours:format(Round(seconds / 3600))
    elseif seconds >= 60 then
        return L.ColorRangeMinutes:format(Round(seconds / 60))
    else
        return L.ColorRangeSeconds:format(seconds)
    end
end

function Addon:FormatColorRange(prevThreshold, currentThreshold)
    if prevThreshold then
        return L.ColorRangeTo:format(self:FormatDuration(prevThreshold), self:FormatDuration(currentThreshold))
    else
        return L.ColorRangeOrLess:format(self:FormatDuration(currentThreshold))
    end
end

function Addon:FormatDefaultColorRange(lastThreshold)
    if lastThreshold then
        return L.ColorRangeAbove:format(self:FormatDuration(lastThreshold))
    else
        return L.ColorRangeAll
    end
end

function Addon:ParseThreshold(val)
    local num = tonumber(strtrim(val))

    if num and num > 0 then
        return num
    end

    return nil
end

function Addon.StackLayout(parent, padX, padY, spacing)
    local layout = {
        parent = parent,
        padX = padX,
        padY = padY,
        spacing = spacing,
        y = padY,
    }

    function layout:Add(frame)
        frame:SetPoint("TOPLEFT", self.parent, "TOPLEFT", self.padX, -self.y)
        frame:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", -self.padX, -self.y)
        self.y = self.y + frame:GetHeight() + self.spacing
        return frame
    end

    function layout:Finish()
        local h = self.y - self.spacing + self.padY
        self.parent:SetHeight(math.max(1, h))
    end

    return layout
end

function Addon:CreateSection(parent, title)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.4)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)

    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleText:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -PAD + 2)
    titleText:SetText(title)

    local INNER_TOP = PAD + SECTION_TITLE_HEIGHT + SPACING
    frame:SetHeight(INNER_TOP + PAD)

    local currentY = INNER_TOP
    local count = 0

    function frame:AddChild(child)
        if count > 0 then currentY = currentY + SPACING end
        count = count + 1
        child:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -currentY)
        child:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PAD, -currentY)
        currentY = currentY + child:GetHeight()
        frame:SetHeight(currentY + PAD)
    end

    return frame
end

Addon.RowHighlightMixin = {}

function Addon.RowHighlightMixin:OnLoad()
    self:EnableMouse(true)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)

    local bg = self:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.06)
    bg:Hide()
    self.HoverBackground = bg
end

function Addon.RowHighlightMixin:OnEnter()
    self.HoverBackground:Show()
    if self.tooltipTitle then
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(self.tooltipTitle, 1, 0.82, 0)
        if self.tooltipText then
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end
end

function Addon.RowHighlightMixin:OnLeave()
    if not self:IsMouseOver() then
        self.HoverBackground:Hide()
        GameTooltip_Hide()
    end
end

function Addon.RowHighlightMixin:RegisterHighlightChild(child)
    local row = self
    child:HookScript("OnEnter", function() row:OnEnter() end)
    child:HookScript("OnLeave", function() row:OnLeave() end)
end

function Addon:CreateRow(parent, height, opts)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(height)

    Mixin(row, self.RowHighlightMixin)
    row:OnLoad()

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", row, "LEFT", 0, 0)
    label:SetWidth(LABEL_COL_WIDTH)
    label:SetJustifyH("LEFT")
    row.label = label

    if opts then
        if opts.name then label:SetText(opts.name) end
        if opts.desc then
            row.tooltipTitle = opts.name
            row.tooltipText = opts.desc
        end
    end

    return row
end

local PANEL_HEADER_HEIGHT = 50

function Addon:CreatePanelHeader(container, title)
    local header = CreateFrame("Frame", nil, container)
    header:SetHeight(PANEL_HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    local titleText = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    titleText:SetPoint("TOPLEFT", header, "TOPLEFT", 7, -22)
    titleText:SetText(title)

    local divider = header:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("Options_HorizontalDivider", TextureKitConstants.UseAtlasSize)
    divider:SetPoint("TOP", header, "TOP", 0, -PANEL_HEADER_HEIGHT)

    return header
end
