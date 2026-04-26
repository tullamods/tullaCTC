local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

local PADDING = Addon.PADDING
local SPACING = Addon.SPACING
local DROPDOWN_HEIGHT = Addon.DROPDOWN_HEIGHT

local DRAW_ORDER = {
    "default",
    "always",
    "never",
}

local DRAW_VALUES = {
    default = L.DrawState_default,
    always  = L.DrawState_always,
    never   = L.DrawState_never,
}

local ROUNDING_MODE_VALUES = {
    Up = L.RoundingMode_Up,
    Down = L.RoundingMode_Down,
    Nearest = L.RoundingMode_Nearest
}

local ROUNDING_MODE_ORDER = { "Nearest", "Up", "Down" }

local function parseThreshold(val)
    local num = tonumber(strtrim(val))
    if num and num > 0 then return num end
    return nil
end

StaticPopupDialogs["TULLACTC_NEW_THEME"] = {
    text = L.EnterThemeName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnAccept = function(self, baseThemeID)
        local name = self.EditBox:GetText():trim()
        if name ~= "" and not Addon:HasTheme("custom_" .. name) then
            local newID = Addon:CreateTheme(name, baseThemeID)
            if newID then
                Addon:SelectAndRefreshTheme(newID)
            end
        end
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["TULLACTC_DELETE_THEME"] = {
    text = L.DeleteThemeConfirm,
    button1 = DELETE,
    button2 = CANCEL,
    OnAccept = function(_, themeID)
        if Addon:DeleteTheme(themeID) then
            Addon:SelectAndRefreshTheme("default")
        end
    end,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["TULLACTC_RENAME_THEME"] = {
    text = L.EnterThemeName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnShow = function(self, themeID)
        self.EditBox:SetText(Addon.GetThemeDisplayName(themeID) or "")
        self.EditBox:HighlightText()
    end,
    OnAccept = function(self, themeID)
        local name = self.EditBox:GetText():trim()
        if name ~= "" then
            Addon:SetThemeProperty(themeID, 'displayName', name)
            Addon:TriggerEvent("OnThemeListChanged")
        end
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    whileDead = true,
    hideOnEscape = true,
}

local selectedThemeId = "default"

local function getSelectedThemeID()
    return selectedThemeId
end

local function setSelectedThemeId(id)
    if Addon:HasTheme(id) then
        selectedThemeId = id
        return true
    end
    return false
end

function Addon:SelectAndRefreshTheme(id)
    if setSelectedThemeId(id) and self._refreshThemeContent then
        self._refreshThemeContent()
    end
end

local function generateThemeMenu(_, rootDescription)
    for _, id in ipairs(Addon:GetSortedThemeIDs()) do
        local name = Addon.GetThemeDisplayName(id)

        local themeEntry = rootDescription:CreateRadio(name,
            function() return getSelectedThemeID() == id end,
            function() Addon:SelectAndRefreshTheme(id) end
        )

        themeEntry:CreateButton(L.CopyTheme, function()
            StaticPopup_Show("TULLACTC_NEW_THEME", nil, nil, id)
        end)

        if id ~= "default" then
            themeEntry:CreateButton(L.RenameTheme, function()
                StaticPopup_Show("TULLACTC_RENAME_THEME", nil, nil, id)
            end)
        end

        themeEntry:CreateDivider()

        themeEntry:CreateButton(L.ResetTheme, function()
            local newID = Addon:ResetTheme(id)
            if newID then
                Addon:SelectAndRefreshTheme(newID)
            end
        end)

        if id ~= "default" then
            themeEntry:CreateButton(L.DeleteTheme, function()
                StaticPopup_Show("TULLACTC_DELETE_THEME", name, nil, id)
            end)
        end
    end

    rootDescription:CreateDivider()

    rootDescription:CreateButton(L.NewTheme, function()
        StaticPopup_Show("TULLACTC_NEW_THEME")
    end)
end

StaticPopupDialogs["TULLACTC_ADD_COLOR"] = {
    text = L.AddColorThreshold,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnAccept = function(self, themeID)
        local threshold = parseThreshold(self.EditBox:GetText())
        if threshold then
            Addon:AddTextColorEntry(themeID, threshold, "FFFFFFFF")
        end
    end,
    OnShow = function(self)
        self.EditBox:SetNumeric(true)
        self.EditBox:SetText("")
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    whileDead = true,
    hideOnEscape = true,
}

local function makeSectionHeader(parent, text, isSubSection)
    local h = CreateFrame("Frame", nil, parent, "SettingsListSectionHeaderTemplate")
    h.Title:ClearAllPoints()

    if isSubSection then
        h:SetHeight(35)
        h.Title:SetFontObject(GameFontHighlight)
        h.Title:SetPoint("TOPLEFT", h, "TOPLEFT", 0, -10)
    else
        h:SetHeight(45)
        h.Title:SetPoint("TOPLEFT", h, "TOPLEFT", 0, -10)
    end

    h.Title:SetText(text)
    return h
end

local function onThemePropertyChanged(_, property, value)
    Addon:SetThemeProperty(getSelectedThemeID(), property, value)
end

local function buildThemeContent(scrollChild, theme)
    local refreshables = {}
    local nextIndex = 1

    local function addChild(w)
        w.layoutIndex = nextIndex
        w.expand = true
        nextIndex = nextIndex + 1
        if w.Refresh then
            refreshables[#refreshables + 1] = w
            w:RegisterCallback("OnValueChanged", onThemePropertyChanged, Addon)
        end
        return w
    end

    local function add(method, opts)
        opts.parent = scrollChild
        opts.data = theme
        return addChild(Addon[method](Addon, opts))
    end

    add("AddCheckBox", {
        property = 'enabled',
        name = L.ThemeEnabled,
        desc = L.ThemeEnabledDesc,
    })

    add("AddSectionCheckBox", {
        property = 'themeCooldown',
        name = L.CooldownAppearance,
        desc = L.ThemeCooldownDesc,
    })

    add("AddDropdown", {
        property = 'drawSwipe',
        name = L.DrawSwipe,
        desc = L.DrawSwipeDesc,
        values = DRAW_VALUES,
        order = DRAW_ORDER,
    })

    add("AddDropdown", {
        property = 'drawEdge',
        name = L.DrawEdge,
        desc = L.DrawEdgeDesc,
        values = DRAW_VALUES,
        order = DRAW_ORDER,
    })

    add("AddDropdown", {
        property = 'drawBling',
        name = L.DrawBling,
        desc = L.DrawBlingDesc,
        values = DRAW_VALUES,
        order = DRAW_ORDER,
    })

    add("AddDropdown", {
        property = 'reverse',
        name = L.Reverse,
        desc = L.ReverseDesc,
        values = DRAW_VALUES,
        order = DRAW_ORDER,
    })

    add("AddCheckBoxColorPicker", {
        checkProperty = 'themeSwipeColor',
        colorProperty = 'swipeColor',
        name = L.SwipeColor,
        desc = L.SwipeColorDesc,
        default = "00000000",
    })

    add("AddSectionCheckBox", {
        property = 'themeText',
        name = L.CountdownText,
        desc = L.ThemeTextDesc,
    })

    add("AddDropdown", {
        property = 'drawText',
        name = L.DrawText,
        desc = L.DrawTextDesc,
        values = DRAW_VALUES,
        order = DRAW_ORDER,
    })

    add("AddDropdown", {
        property = 'roundingMode',
        name = L.RoundingMode,
        desc = L.RoundingModeDesc,
        values = ROUNDING_MODE_VALUES,
        order = ROUNDING_MODE_ORDER
    })

    add("AddCheckBox", {
        property = 'showZero',
        name = L.ShowZero,
        desc = L.ShowZeroDesc,
    })

    add("AddSlider", {
        property = 'minDuration',
        name = L.MinDuration,
        desc = L.MinDurationDesc,
        min = 0,
        max = 60,
        default = 3,
    })

    add("AddSlider", {
        property = 'tenthsThreshold',
        name = L.TenthsThreshold,
        desc = L.TenthsThresholdDesc,
        min = 0,
        max = 60,
        default = 0,
    })

    add("AddSlider", {
        property = 'abbrevThreshold',
        name = L.AbbrevThreshold,
        desc = L.AbbrevThresholdDesc,
        min = 0,
        max = 600,
        default = 90,
    })

    addChild(makeSectionHeader(scrollChild, L.TextFont, true))

    add("AddFontSelector", { property = 'font', name = L.FontFace })

    add("AddDropdown", {
        property = 'fontFlags',
        name = L.FontOutline,
        values = {
            ['']                    = L.Outline_NONE,
            ['OUTLINE']             = L.Outline_OUTLINE,
            ['THICKOUTLINE']        = L.Outline_THICKOUTLINE,
            ['OUTLINE, MONOCHROME'] = L.Outline_OUTLINEMONOCHROME,
        },
        order = { '', 'OUTLINE', 'THICKOUTLINE', 'OUTLINE, MONOCHROME' },
    })

    add("AddSlider", {
        property = 'fontSize',
        name = L.FontSize,
        min = 0,
        max = 96,
    })

    addChild(makeSectionHeader(scrollChild, L.TextShadow, true))

    add("AddColorPicker", {
        property = 'shadowColor',
        name = L.TextShadowColor,
        default = "00000000",
    })

    add("AddSlider", {
        property = 'shadowX',
        name = L.HorizontalOffset,
        min = -4,
        max = 4,
    })

    add("AddSlider", {
        property = 'shadowY',
        name = L.VerticalOffset,
        min = -4,
        max = 4,
        invert = true,
    })

    addChild(makeSectionHeader(scrollChild, L.TextPosition, true))

    add("AddDropdown", {
        property = 'point',
        name = L.Anchor,
        values = {
            TOPLEFT = L.Anchor_TOPLEFT,
            TOP = L.Anchor_TOP,
            TOPRIGHT = L.Anchor_TOPRIGHT,
            LEFT = L.Anchor_LEFT,
            CENTER = L.Anchor_CENTER,
            RIGHT = L.Anchor_RIGHT,
            BOTTOMLEFT = L.Anchor_BOTTOMLEFT,
            BOTTOM = L.Anchor_BOTTOM,
            BOTTOMRIGHT = L.Anchor_BOTTOMRIGHT,
        },
        order = { 'TOPLEFT', 'TOP', 'TOPRIGHT', 'LEFT', 'CENTER', 'RIGHT', 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT' },
    })

    add("AddSlider", {
        property = 'offsetX',
        name = L.HorizontalOffset,
        min = -18,
        max = 18,
    })

    add("AddSlider", {
        property = 'offsetY',
        name = L.VerticalOffset,
        min = -18,
        max = 18,
        invert = true,
    })

    local colorsHeader = makeSectionHeader(scrollChild, L.CountdownTextColors)
    local addBtn = CreateFrame("Button", nil, colorsHeader, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("RIGHT", colorsHeader, "RIGHT", 0, 0)
    addBtn:SetText(ADD)
    addBtn:SetScript("OnClick", function()
        StaticPopup_Show("TULLACTC_ADD_COLOR", nil, nil, getSelectedThemeID())
    end)
    addChild(colorsHeader)

    return refreshables, nextIndex
end

function Addon:BuildThemePanel(container)
    local toolbar = CreateFrame("Frame", nil, container)
    toolbar:SetHeight(DROPDOWN_HEIGHT + PADDING * 2)
    toolbar:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    toolbar:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    local themeLabel = toolbar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    themeLabel:SetText(L.SelectTheme)
    themeLabel:SetPoint("LEFT", toolbar, "LEFT", PADDING, 0)

    local themeDD = CreateFrame("DropdownButton", nil, toolbar, "WowStyle1DropdownTemplate")
    themeDD:SetSize(140, DROPDOWN_HEIGHT)
    themeDD:SetPoint("LEFT", themeLabel, "RIGHT", PADDING, 0)
    themeDD:SetupMenu(generateThemeMenu)

    local previewBtn = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    previewBtn:SetSize(80, 22)
    previewBtn:SetPoint("RIGHT", toolbar, "RIGHT", -PADDING, 0)
    previewBtn:SetText(L.Preview)
    previewBtn:SetScript("OnClick", function()
        self:GetPreviewDialog():SetTheme(getSelectedThemeID())
    end)

    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetColorTexture(0.3, 0.3, 0.3, 1)
    divider:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("TOPRIGHT", toolbar, "BOTTOMRIGHT", -14, 0)

    local scrollBox = CreateFrame("Frame", nil, container, "WowScrollBox")
    local scrollBar = CreateFrame("EventFrame", nil, container, "MinimalScrollBar")

    scrollBox:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -1)
    scrollBox:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -14, 0)

    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 2, -10)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 2, 10)

    local scrollChild = CreateFrame("Frame", nil, scrollBox, "VerticalLayoutFrame")
    scrollChild.scrollable = true
    scrollChild.spacing = SPACING
    scrollChild.topPadding = PADDING
    scrollChild.bottomPadding = PADDING
    scrollChild.leftPadding = PADDING
    scrollChild.rightPadding = PADDING
    scrollChild.skipLayoutOnShow = true

    local view = CreateScrollBoxLinearView()
    view:SetPanExtent(50)
    ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)

    scrollChild:ClearAllPoints()
    scrollChild:SetPoint("TOPLEFT", scrollBox.ScrollTarget, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", scrollBox.ScrollTarget, "TOPRIGHT", 0, 0)

    local initialTheme = tullaCTC.db.profile.themes[getSelectedThemeID()]
    local refreshables, nextIndex = buildThemeContent(scrollChild, initialTheme)

    local colorSection = CreateFrame("Frame", nil, scrollChild, "VerticalLayoutFrame")
    colorSection.layoutIndex = nextIndex
    colorSection.expand = true
    colorSection.spacing = SPACING
    colorSection.skipLayoutOnShow = true

    local colorRowPool = Addon:BuildColorRowPool(colorSection)
    for i, row in ipairs(colorRowPool) do
        row.layoutIndex = i
        row.expand = true
    end

    local defaultColorPicker = Addon:AddColorPicker({
        parent = colorSection,
        data = initialTheme,
        property = 'defaultTextColor',
        name = "",
    })

    defaultColorPicker:RegisterCallback("OnValueChanged", onThemePropertyChanged, Addon)
    defaultColorPicker.layoutIndex = #colorRowPool + 1
    defaultColorPicker.expand = true

    local function layoutColorRows()
        local themeID = getSelectedThemeID()
        local theme = tullaCTC.db.profile.themes[themeID]
        local entries = Addon:GetSortedTextColors(themeID)

        for i, row in ipairs(colorRowPool) do
            if i <= #entries then
                local prevThreshold = i > 1 and entries[i - 1].threshold or nil
                Addon.UpdateColorRow(row, entries[i], i, themeID, prevThreshold)
                row:Show()
            else
                row:Hide()
            end
        end

        local prevThreshold = #entries > 0 and entries[#entries].threshold or nil
        defaultColorPicker.data = theme
        defaultColorPicker:Refresh()
        defaultColorPicker:SetLabel(Addon:FormatDefaultColorRange(prevThreshold))

        colorSection:SetFixedWidth(scrollChild:GetFixedWidth())
        scrollChild:Layout()
        scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    end

    local function refreshContent()
        local theme = tullaCTC.db.profile.themes[getSelectedThemeID()]
        themeDD:GenerateMenu()
        for _, w in ipairs(refreshables) do
            w.data = theme
            w:Refresh()
        end
        layoutColorRows()
        scrollBox:ScrollToBegin()
    end

    self._refreshThemeContent = refreshContent

    Addon:RegisterCallback("OnThemeListChanged", function()
        themeDD:GenerateMenu()
    end, container)

    Addon:RegisterCallback("OnThemeColorsChanged", function(_, themeID)
        if themeID == getSelectedThemeID() then
            layoutColorRows()
        end
    end, container)

    local lastWidth = 0
    scrollChild:HookScript("OnSizeChanged", function(_, width)
        if width > 0 and width ~= lastWidth then
            lastWidth = width
            scrollChild:SetFixedWidth(width)
            layoutColorRows()
        end
    end)

    scrollChild:SetFixedWidth(scrollChild:GetWidth())
    layoutColorRows()
end
