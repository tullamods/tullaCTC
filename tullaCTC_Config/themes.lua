local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

local PAD = Addon.PAD
local SPACING = Addon.SPACING
local DROPDOWN_HEIGHT = Addon.DROPDOWN_HEIGHT

StaticPopupDialogs["TULLACTC_NEW_THEME"] = {
    text = L.EnterThemeName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnAccept = function(self)
        local name = self.editBox:GetText():trim()
        if name ~= "" and not Addon:HasTheme("custom_" .. name) then
            local newID = Addon:CreateTheme(name)
            if newID then
                Addon:SelectAndRefreshTheme(newID)
            end
        end
    end,
    EditBoxOnEnterPressed = function(self)
        self:GetParent().button1:Click()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["TULLACTC_COPY_THEME"] = {
    text = L.EnterThemeName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnAccept = function(self, sourceThemeID)
        local name = self.editBox:GetText():trim()
        if name ~= "" and not Addon:HasTheme("custom_" .. name) then
            local newID = Addon:CreateTheme(name, sourceThemeID)
            if newID then
                Addon:SelectAndRefreshTheme(newID)
            end
        end
    end,
    EditBoxOnEnterPressed = function(self)
        self:GetParent().button1:Click()
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
        self.editBox:SetText(Addon.GetThemeDisplayName(themeID) or "")
        self.editBox:HighlightText()
    end,
    OnAccept = function(self, themeID)
        local name = self.editBox:GetText():trim()
        if name ~= "" then
            Addon:SetThemeProperty(themeID, 'displayName', name)
            if activeRefreshContent then activeRefreshContent() end
        end
    end,
    EditBoxOnEnterPressed = function(self)
        self:GetParent().button1:Click()
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

local activeRefreshContent = nil
local activeColorRefresh = nil

function Addon:SelectAndRefreshTheme(id)
    if setSelectedThemeId(id) then
        if activeRefreshContent then
            activeRefreshContent()
        end
    end
end

local function generateThemeMenu(_, rootDescription)
    local themes = tullaCTC.db.profile.themes
    local order = {}

    for id in pairs(themes) do
        order[#order + 1] = id
    end

    table.sort(order, function(a, b)
        return Addon.GetThemeDisplayName(a) < Addon.GetThemeDisplayName(b)
    end)

    for _, id in ipairs(order) do
        local name = Addon.GetThemeDisplayName(id)

        local themeEntry = rootDescription:CreateRadio(name,
            function() return getSelectedThemeID() == id end,
            function() Addon:SelectAndRefreshTheme(id) end)

        themeEntry:CreateButton(L.CopyTheme, function()
            StaticPopup_Show("TULLACTC_COPY_THEME", nil, nil, id)
        end)

        if id ~= "default" then
            themeEntry:CreateButton(L.RenameTheme, function()
                StaticPopup_Show("TULLACTC_RENAME_THEME", nil, nil, id)
            end)
        end

        themeEntry:CreateDivider()

        themeEntry:CreateButton(L.ResetTheme, function()
            if Addon:ResetTheme(id) then
                Addon:RefreshThemeTree()
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

local addColorDialog = nil

local function showAddColorDialog(theme)
    if not addColorDialog then
        local dlg = CreateFrame("Frame", "TullaCTCAddColorDialog", UIParent, "BasicFrameTemplateWithInset")
        dlg:SetSize(280, 152)
        dlg:SetPoint("CENTER")
        dlg:SetClampedToScreen(true)
        dlg:SetFrameStrata("DIALOG")
        dlg:SetMovable(true)
        dlg:RegisterForDrag("LeftButton")
        dlg:SetScript("OnDragStart", dlg.StartMoving)
        dlg:SetScript("OnDragStop", dlg.StopMovingOrSizing)
        dlg.TitleText:SetText(L.AddColorThreshold)
        dlg.CloseButton:SetScript("OnClick", function() dlg:Hide() end)
        tinsert(UISpecialFrames, "TullaCTCAddColorDialog")

        local LABEL_W = 70
        local MARGIN = PAD + 4
        local CONTROL_X = MARGIN + LABEL_W + PAD
        local ROW_H = 24
        local ROW_Y1 = 40
        local ROW_Y2 = ROW_Y1 + ROW_H + SPACING

        local durationLabel = dlg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        durationLabel:SetSize(LABEL_W, ROW_H)
        durationLabel:SetPoint("TOPLEFT", dlg, "TOPLEFT", MARGIN, -ROW_Y1)
        durationLabel:SetJustifyH("RIGHT")
        durationLabel:SetJustifyV("MIDDLE")
        durationLabel:SetText(L.Duration)

        local durationBox = CreateFrame("EditBox", nil, dlg, "InputBoxTemplate")
        durationBox:SetHeight(20)
        durationBox:SetAutoFocus(false)
        durationBox:SetNumeric(true)
        durationBox:SetPoint("TOPLEFT", dlg, "TOPLEFT", CONTROL_X, -(ROW_Y1 + 2))
        durationBox:SetPoint("TOPRIGHT", dlg, "TOPRIGHT", -MARGIN, -(ROW_Y1 + 2))
        dlg.durationBox = durationBox

        local colorLabel = dlg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        colorLabel:SetSize(LABEL_W, ROW_H)
        colorLabel:SetPoint("TOPLEFT", dlg, "TOPLEFT", MARGIN, -ROW_Y2)
        colorLabel:SetJustifyH("RIGHT")
        colorLabel:SetJustifyV("MIDDLE")
        colorLabel:SetText(L.TextColor)

        local swatchBtn = CreateFrame("Button", nil, dlg)
        swatchBtn:SetSize(26, 25)
        swatchBtn:SetPoint("TOPLEFT", dlg, "TOPLEFT", CONTROL_X, -ROW_Y2)

        local swBg = swatchBtn:CreateTexture(nil, "BACKGROUND")
        swBg:SetAtlas("common-dropdown-c-button", TextureKitConstants.UseAtlasSize)
        swBg:SetPoint("CENTER")

        local swTex = swatchBtn:CreateTexture(nil, "ARTWORK")
        swTex:SetPoint("TOPLEFT", 4, -3)
        swTex:SetPoint("BOTTOMRIGHT", -4, 3)

        local function updateSwatch()
            local r, g, b, a = Addon.HexToRGBA(dlg.pendingColor)
            swTex:SetColorTexture(r, g, b, a)
        end
        dlg.updateSwatch = updateSwatch

        swatchBtn:SetScript("OnClick", function()
            local r, g, b, a = Addon.HexToRGBA(dlg.pendingColor)
            ColorPickerFrame:SetupColorPickerAndShow({
                r = r, g = g, b = b,
                opacity = 1 - a, hasOpacity = true,
                swatchFunc = function()
                    local r2, g2, b2 = ColorPickerFrame:GetColorRGB()
                    local a2 = 1 - ColorPickerFrame:GetColorAlpha()
                    dlg.pendingColor = Addon.RGBAToHex(r2, g2, b2, a2)
                    updateSwatch()
                end,
                cancelFunc = function(prev)
                    dlg.pendingColor = Addon.RGBAToHex(prev.r, prev.g, prev.b, 1 - (prev.opacity or 0))
                    updateSwatch()
                end,
            })
        end)

        local acceptBtn = CreateFrame("Button", nil, dlg, "UIPanelButtonTemplate")
        acceptBtn:SetSize(80, 22)
        acceptBtn:SetPoint("BOTTOMRIGHT", dlg, "BOTTOM", -PAD / 2, PAD + 4)
        acceptBtn:SetText(ACCEPT)

        local function tryAccept()
            local threshold = Addon:ParseThreshold(dlg.durationBox:GetNumber())
            if threshold and Addon:AddTextColorEntry(dlg.currentTheme, threshold, dlg.pendingColor) then
                Addon:RefreshThemeTree()
                dlg:Hide()
            end
        end

        acceptBtn:SetScript("OnClick", tryAccept)
        durationBox:SetScript("OnEnterPressed", tryAccept)
        durationBox:SetScript("OnEscapePressed", function() dlg:Hide() end)

        local cancelBtn = CreateFrame("Button", nil, dlg, "UIPanelButtonTemplate")
        cancelBtn:SetSize(80, 22)
        cancelBtn:SetPoint("BOTTOMLEFT", dlg, "BOTTOM", PAD / 2, PAD + 4)
        cancelBtn:SetText(CANCEL)
        cancelBtn:SetScript("OnClick", function() dlg:Hide() end)

        addColorDialog = dlg
    end

    addColorDialog.currentTheme = theme
    addColorDialog.pendingColor = "FFFFFFFF"
    addColorDialog.updateSwatch()
    addColorDialog.durationBox:SetText("")
    addColorDialog:Show()
    addColorDialog.durationBox:SetFocus()
end

local function makeSectionHeader(parent, text)
    local h = CreateFrame("Frame", nil, parent, "SettingsListSectionHeaderTemplate")
    h:SetHeight(45)
    h.Title:SetText(text)
    return h
end

local function makeSectionCheckBox(parent, themeID, property, title, desc)
    local h = CreateFrame("Frame", nil, parent, "SettingsListSectionHeaderTemplate")
    h:SetHeight(45)
    h.Title:SetText(title)

    local cb = CreateFrame("CheckButton", nil, h, "SettingsCheckboxTemplate")
    cb:SetPoint("LEFT", h, "LEFT", 0, 0)
    h.Title:ClearAllPoints()
    h.Title:SetPoint("LEFT", cb, "RIGHT", PAD, 0)
    cb:Init(tullaCTC.db.profile.themes[themeID][property])
    if cb.HoverBackground then cb.HoverBackground:Hide() end

    local updating = false
    cb:RegisterCallback(SettingsCheckboxMixin.Event.OnValueChanged, function(_, checked)
        if not updating then
            Addon:SetThemeProperty(themeID, property, checked)
        end
    end)

    function h:Refresh(newID)
        themeID = newID
        updating = true
        cb:Init(tullaCTC.db.profile.themes[themeID][property])
        updating = false
    end

    return h
end

local function makeSubSectionHeader(parent, text)
    local h = CreateFrame("Frame", nil, parent, "SettingsListSectionHeaderTemplate")
    h:SetHeight(35)
    h.Title:SetFontObject(GameFontNormal)
    h.Title:SetText(text)
    return h
end

local function buildThemeContent(scrollChild, initialThemeID)
    local layout = Addon.StackLayout(scrollChild, PAD, PAD, SPACING)
    local refreshables = {}

    local function addWidget(w)
        layout:Add(w)
        if w.Refresh then
            refreshables[#refreshables + 1] = w
        end
        return w
    end

    addWidget(Addon:AddCheckBox(scrollChild, initialThemeID, 'enabled', {
        name = L.ThemeEnabled,
        desc = L.ThemeEnabledDesc,
    }))

    addWidget(makeSectionCheckBox(scrollChild, initialThemeID, 'themeCooldown', L.CooldownAppearance, L.ThemeCooldownDesc))
    addWidget(Addon:AddDrawStateDropdown(scrollChild, initialThemeID, 'drawSwipe', {
        name = L.DrawSwipe,
        desc = L.DrawSwipeDesc,
    }))
    addWidget(Addon:AddDrawStateDropdown(scrollChild, initialThemeID, 'drawEdge', {
        name = L.DrawEdge,
        desc = L.DrawEdgeDesc,
    }))
    addWidget(Addon:AddDrawStateDropdown(scrollChild, initialThemeID, 'drawBling', {
        name = L.DrawBling,
        desc = L.DrawBlingDesc,
    }))
    addWidget(Addon:AddDrawStateDropdown(scrollChild, initialThemeID, 'reverse', {
        name = L.Reverse,
        desc = L.ReverseDesc,
    }))
    addWidget(Addon:AddCheckBoxColorPicker(scrollChild, initialThemeID, 'themeSwipeColor', 'swipeColor', {
        name = L.SwipeColor,
        desc = L.SwipeColorDesc,
        default = "00000000",
    }))

    addWidget(makeSectionCheckBox(scrollChild, initialThemeID, 'themeText', L.CountdownText, L.ThemeTextDesc))
    addWidget(Addon:AddDrawStateDropdown(scrollChild, initialThemeID, 'drawText', {
        name = L.DrawText,
        desc = L.DrawTextDesc,
    }))
    addWidget(Addon:AddDrawStateDropdown(scrollChild, initialThemeID, 'useAuraDisplayTime', {
        name = L.UseAuraDisplayTime,
        desc = L.UseAuraDisplayTimeDesc,
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'minDuration', {
        name = L.MinDuration,
        desc = L.MinDurationDesc,
        min = 0, max = 60, default = 3,
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'tenthsThreshold', {
        name = L.TenthsThreshold,
        desc = L.TenthsThresholdDesc,
        min = 0, max = 10, default = 0,
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'abbrevThreshold', {
        name = L.AbbrevThreshold,
        desc = L.AbbrevThresholdDesc,
        min = 0, max = 600, default = 90,
    }))

    layout:Add(makeSubSectionHeader(scrollChild, L.TextFont))
    addWidget(Addon:AddFontSelector(scrollChild, initialThemeID, 'font', { name = L.FontFace }))
    addWidget(Addon:AddDropdown(scrollChild, initialThemeID, 'fontFlags', {
        name = L.FontOutline,
        values = {
            ['']                    = L.Outline_NONE,
            ['OUTLINE']             = L.Outline_OUTLINE,
            ['THICKOUTLINE']        = L.Outline_THICKOUTLINE,
            ['OUTLINE, MONOCHROME'] = L.Outline_OUTLINEMONOCHROME,
        },
        order = { '', 'OUTLINE', 'THICKOUTLINE', 'OUTLINE, MONOCHROME' },
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'fontSize', {
        name = L.FontSize, min = 0, max = 36,
    }))

    layout:Add(makeSubSectionHeader(scrollChild, L.TextShadow))
    addWidget(Addon:AddColorPicker(scrollChild, initialThemeID, 'shadowColor', {
        name = L.TextShadowColor, default = "00000000",
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'shadowX', {
        name = L.HorizontalOffset, min = -4, max = 4,
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'shadowY', {
        name = L.VerticalOffset, min = -4, max = 4, invert = true,
    }))

    layout:Add(makeSubSectionHeader(scrollChild, L.TextPosition))
    addWidget(Addon:AddDropdown(scrollChild, initialThemeID, 'point', {
        name = L.Anchor,
        values = {
            TOPLEFT = L.Anchor_TOPLEFT, TOP = L.Anchor_TOP, TOPRIGHT = L.Anchor_TOPRIGHT,
            LEFT    = L.Anchor_LEFT,    CENTER = L.Anchor_CENTER,  RIGHT = L.Anchor_RIGHT,
            BOTTOMLEFT = L.Anchor_BOTTOMLEFT, BOTTOM = L.Anchor_BOTTOM, BOTTOMRIGHT = L.Anchor_BOTTOMRIGHT,
        },
        order = { 'TOPLEFT','TOP','TOPRIGHT','LEFT','CENTER','RIGHT','BOTTOMLEFT','BOTTOM','BOTTOMRIGHT' },
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'offsetX', {
        name = L.HorizontalOffset, min = -18, max = 18,
    }))
    addWidget(Addon:AddSlider(scrollChild, initialThemeID, 'offsetY', {
        name = L.VerticalOffset, min = -18, max = 18, invert = true,
    }))

    local colorsHeader = makeSectionHeader(scrollChild, L.CountdownTextColors)
    local addBtn = CreateFrame("Button", nil, colorsHeader, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("RIGHT", colorsHeader, "RIGHT", 0, 0)
    addBtn:SetText(ADD)
    addBtn:SetScript("OnClick", function()
        showAddColorDialog(tullaCTC.db.profile.themes[getSelectedThemeID()])
    end)
    layout:Add(colorsHeader)

    return refreshables, layout.y
end

function Addon:RefreshThemeTree()
    if activeColorRefresh then activeColorRefresh() end
end

function Addon:RefreshThemePanel()
    if activeRefreshContent then activeRefreshContent() end
end

function Addon:BuildThemePanel(container)
    local toolbar = CreateFrame("Frame", nil, container)
    toolbar:SetHeight(DROPDOWN_HEIGHT + PAD * 2)
    toolbar:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    toolbar:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    local themeLabel = toolbar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    themeLabel:SetText(L.SelectTheme)
    themeLabel:SetPoint("LEFT", toolbar, "LEFT", PAD, 0)

    local themeDD = CreateFrame("DropdownButton", nil, toolbar, "WowStyle1DropdownTemplate")
    themeDD:SetSize(140, DROPDOWN_HEIGHT)
    themeDD:SetPoint("LEFT", themeLabel, "RIGHT", PAD, 0)
    themeDD:SetupMenu(generateThemeMenu)

    local previewBtn = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    previewBtn:SetSize(80, 22)
    previewBtn:SetPoint("RIGHT", toolbar, "RIGHT", -PAD, 0)
    previewBtn:SetText(L.Preview)
    previewBtn:SetScript("OnClick", function()
        self.PreviewDialog:SetTheme(getSelectedThemeID())
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

    local scrollChild = CreateFrame("Frame", nil, scrollBox)
    scrollChild.scrollable = true

    local view = CreateScrollBoxLinearView()
    view:SetPanExtent(50)
    ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)

    scrollChild:ClearAllPoints()
    scrollChild:SetPoint("TOPLEFT", scrollBox.ScrollTarget, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", scrollBox.ScrollTarget, "TOPRIGHT", 0, 0)

    local refreshables, colorRowsY = buildThemeContent(scrollChild, getSelectedThemeID())

    local colorSection = CreateFrame("Frame", nil, scrollChild)
    colorSection:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", PAD, -colorRowsY)
    colorSection:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -PAD, -colorRowsY)

    local colorRowPool = Addon:BuildColorRowPool(colorSection)
    local defaultColorPicker = Addon:AddColorPicker(colorSection, getSelectedThemeID(), 'defaultTextColor', {
        name = "",
    })

    local function layoutColorSection()
        local y = 0
        for _, row in ipairs(colorRowPool) do
            if row:IsShown() then
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", colorSection, "TOPLEFT", 0, -y)
                row:SetPoint("TOPRIGHT", colorSection, "TOPRIGHT", 0, -y)
                y = y + row:GetHeight() + SPACING
            end
        end
        defaultColorPicker:ClearAllPoints()
        defaultColorPicker:SetPoint("TOPLEFT", colorSection, "TOPLEFT", 0, -y)
        defaultColorPicker:SetPoint("TOPRIGHT", colorSection, "TOPRIGHT", 0, -y)
        y = y + defaultColorPicker:GetHeight() + SPACING
        local h = math.max(1, y - SPACING)
        colorSection:SetHeight(h)
        scrollChild:SetHeight(colorRowsY + h + PAD)
        scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    end

    local function layoutColorRows()
        local currentID = getSelectedThemeID()
        local theme = tullaCTC.db.profile.themes[currentID]
        local entries = Addon:GetSortedTextColors(theme)

        for i, row in ipairs(colorRowPool) do
            if i <= #entries then
                local prevThreshold = i > 1 and entries[i - 1].threshold or nil
                row:Update(entries[i], i, theme, prevThreshold)
                row:Show()
            else
                row:Hide()
            end
        end

        local prevThreshold = #entries > 0 and entries[#entries].threshold or nil
        defaultColorPicker:Refresh(currentID)
        defaultColorPicker:SetLabel(Addon:FormatDefaultColorRange(prevThreshold))

        layoutColorSection()
    end

    local function refreshContent()
        local newID = getSelectedThemeID()
        themeDD:GenerateMenu()
        for _, w in ipairs(refreshables) do
            w:Refresh(newID)
        end
        layoutColorRows()
        scrollBox:ScrollToBegin()
    end

    activeRefreshContent = refreshContent
    activeColorRefresh = layoutColorRows

    layoutColorRows()
end
