local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local LSM = LibStub('LibSharedMedia-3.0')
local AceGUI = LibStub('AceGUI-3.0')
local tullaCTC = _G.tullaCTC

--------------------------------------------------------------------------------
-- Static Popup Dialogs
--------------------------------------------------------------------------------

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
    text = L.EnterCopyName,
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

-- Track the currently selected theme
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

local function getThemeDisplayName(id)
    local theme = tullaCTC.db.profile.themes[id]
    if theme then
        return theme.displayName or rawget(L, 'Theme_' .. id) or id
    end
    return id
end

function Addon:SelectAndRefreshTheme(id)
    if setSelectedThemeId(id) then
        self:RefreshThemePanel()
    end
end

--------------------------------------------------------------------------------
-- Theme Context Menu
--------------------------------------------------------------------------------

local function generateThemeMenu(_, rootDescription)
    local themes = tullaCTC.db.profile.themes
    local order = {}

    for id in pairs(themes) do
        order[#order + 1] = id
    end

    table.sort(order, function(a, b)
        return getThemeDisplayName(a) < getThemeDisplayName(b)
    end)

    for _, id in ipairs(order) do
        local name = getThemeDisplayName(id)

        local themeEntry = rootDescription:CreateButton(name, function()
            Addon:SelectAndRefreshTheme(id)
        end)

        themeEntry:CreateButton(L.CopyTheme, function()
            StaticPopup_Show("TULLACTC_COPY_THEME", nil, nil, id)
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

--------------------------------------------------------------------------------
-- Tree Node Builders
--------------------------------------------------------------------------------

local function buildGeneralOptions(container, themeID)
    container:SetLayout("Flow")

    Addon:AddCheckBox(container, themeID, 'enabled', {
        name = L.ThemeEnabled,
        desc = L.ThemeEnabledDesc,
        fullWidth = true,
    })

    -- cooldown text section
    local textGroup = AceGUI:Create("InlineGroup")
    textGroup:SetTitle(L.CooldownText)
    textGroup:SetFullWidth(true)
    textGroup:SetLayout("Flow")

    Addon:AddCheckBox(textGroup, themeID, 'themeText', {
        name = L.ThemeText,
        desc = L.ThemeTextDesc,
        fullWidth = true,
    })

    Addon:AddDrawStateDropdown(textGroup, themeID, 'drawText', {
        name = L.DrawText,
        desc = L.DrawTextDesc,
    })

    Addon:AddDrawStateDropdown(textGroup, themeID, 'useAuraDisplayTime', {
        name = L.UseAuraDisplayTime,
        desc = L.UseAuraDisplayTimeDesc,
    })

    Addon:AddSlider(textGroup, themeID, 'minDuration', {
        name = L.MinDuration,
        desc = L.MinDurationDesc,
        min = 0,
        softMax = 60,
        default = 3,
        fullWidth = true,
    })

    Addon:AddSlider(textGroup, themeID, 'abbrevThreshold', {
        name = L.AbbrevThreshold,
        desc = L.AbbrevThresholdDesc,
        min = 0,
        softMax = 600,
        default = 90,
        fullWidth = true,
    })

    container:AddChild(textGroup)

    -- cooldown frame section
    local cdGroup = AceGUI:Create("InlineGroup")
    cdGroup:SetTitle(L.Cooldown)
    cdGroup:SetFullWidth(true)
    cdGroup:SetLayout("Flow")

    Addon:AddCheckBox(cdGroup, themeID, 'themeCooldown', {
        name = L.ThemeCooldown,
        desc = L.ThemeCooldownDesc,
        fullWidth = true,
    })

    Addon:AddDrawStateDropdown(cdGroup, themeID, 'drawSwipe', {
        name = L.DrawSwipe,
        desc = L.DrawSwipeDesc,
    })

    Addon:AddDrawStateDropdown(cdGroup, themeID, 'drawEdge', {
        name = L.DrawEdge,
        desc = L.DrawEdgeDesc,
    })

    Addon:AddDrawStateDropdown(cdGroup, themeID, 'drawBling', {
        name = L.DrawBling,
        desc = L.DrawBlingDesc,
    })

    Addon:AddDrawStateDropdown(cdGroup, themeID, 'reverse', {
        name = L.Reverse,
        desc = L.ReverseDesc,
    })

    Addon:AddCheckBox(cdGroup, themeID, 'themeSwipeColor', {
        name = L.ThemeSwipeColor,
    })

    Addon:AddColorPicker(cdGroup, themeID, 'swipeColor', {
        name = L.SwipeColor,
        desc = L.SwipeColorDesc,
        default = "00000000",
    })

    container:AddChild(cdGroup)
end

local function buildTextOptions(container, themeID)
    container:SetLayout("Flow")

    -- font section
    local fontGroup = AceGUI:Create("InlineGroup")
    fontGroup:SetTitle(L.TextFont)
    fontGroup:SetFullWidth(true)
    fontGroup:SetLayout("Flow")

    -- font face via LSM widget
    local fontWidget = AceGUI:Create("LSM30_Font")
    fontWidget:SetLabel(L.FontFace)
    fontWidget:SetList(LSM:HashTable('font'))
    fontWidget:SetValue(tullaCTC.db.profile.themes[themeID].font)
    fontWidget:SetFullWidth(true)
    fontWidget:SetCallback("OnValueChanged", function(_, _, val)
        Addon:SetThemeProperty(themeID, 'font', val)
    end)
    fontGroup:AddChild(fontWidget)

    Addon:AddDropdown(fontGroup, themeID, 'fontFlags', {
        name = L.FontOutline,
        default = 'OUTLINE',
        fullWidth = true,
        values = {
            [''] = L.Outline_NONE,
            OUTLINE = L.Outline_OUTLINE,
            THICKOUTLINE = L.Outline_THICKOUTLINE,
            ['OUTLINE, MONOCHROME'] = L.Outline_OUTLINEMONOCHROME,
        },
    })

    Addon:AddSlider(fontGroup, themeID, 'fontSize', {
        name = L.FontSize,
        min = 0,
        softMax = 36,
        fullWidth = true,
    })

    container:AddChild(fontGroup)

    -- shadow section
    local shadowGroup = AceGUI:Create("InlineGroup")
    shadowGroup:SetTitle(L.TextShadow)
    shadowGroup:SetFullWidth(true)
    shadowGroup:SetLayout("Flow")

    Addon:AddColorPicker(shadowGroup, themeID, 'shadowColor', {
        name = L.TextShadowColor,
        default = "00000000",
    })

    Addon:AddSlider(shadowGroup, themeID, 'shadowX', {
        name = L.HorizontalOffset,
        softMin = -4,
        softMax = 4,
        fullWidth = true,
    })

    Addon:AddSlider(shadowGroup, themeID, 'shadowY', {
        name = L.VerticalOffset,
        softMin = -4,
        softMax = 4,
        invert = true,
        fullWidth = true,
    })

    container:AddChild(shadowGroup)

    -- position section
    local posGroup = AceGUI:Create("InlineGroup")
    posGroup:SetTitle(L.TextPosition)
    posGroup:SetFullWidth(true)
    posGroup:SetLayout("Flow")

    Addon:AddDropdown(posGroup, themeID, 'point', {
        name = L.Anchor,
        default = 'CENTER',
        fullWidth = true,
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
    })

    Addon:AddSlider(posGroup, themeID, 'offsetX', {
        name = L.HorizontalOffset,
        softMin = -18,
        softMax = 18,
        fullWidth = true,
    })

    Addon:AddSlider(posGroup, themeID, 'offsetY', {
        name = L.VerticalOffset,
        softMin = -18,
        softMax = 18,
        invert = true,
        fullWidth = true,
    })

    container:AddChild(posGroup)
end

local function buildColorOptions(container, themeID)
    container:SetLayout("Flow")

    local theme = tullaCTC.db.profile.themes[themeID]

    -- description
    local desc = AceGUI:Create("Label")
    desc:SetText(L.ColorsDescription)
    desc:SetFullWidth(true)
    container:AddChild(desc)

    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    container:AddChild(spacer)

    -- add threshold row
    local addGroup = AceGUI:Create("InlineGroup")
    addGroup:SetTitle(L.AddColorThreshold)
    addGroup:SetFullWidth(true)
    addGroup:SetLayout("Flow")

    local addEditBox = AceGUI:Create("EditBox")
    addEditBox:SetLabel(L.NewThresholdValue)
    addEditBox:SetRelativeWidth(0.6)
    addEditBox:SetCallback("OnEnterPressed", function(widget, _, val)
        local threshold = Addon:ParseThreshold(val)
        if threshold and Addon:AddTextColorEntry(theme, threshold) then
            widget:SetText("")
            Addon:RefreshThemeTree()
        end
    end)
    addGroup:AddChild(addEditBox)
    container:AddChild(addGroup)

    -- color threshold entries
    local entries = Addon:GetSortedTextColors(theme)
    local prevThreshold = nil

    for i, entry in ipairs(entries) do
        local threshold = entry.threshold

        local group = AceGUI:Create("InlineGroup")
        group:SetTitle(Addon:FormatEffectiveRange(prevThreshold, threshold))
        group:SetFullWidth(true)
        group:SetLayout("Flow")

        local thresholdBox = AceGUI:Create("EditBox")
        thresholdBox:SetLabel(L.Threshold)
        thresholdBox:SetText(tostring(entry.threshold))
        thresholdBox:SetRelativeWidth(0.35)
        thresholdBox:SetCallback("OnEnterPressed", function(widget, _, val)
            local newThreshold = Addon:ParseThreshold(val)
            if newThreshold and Addon:SetTextColorThreshold(theme, i, newThreshold) then
                Addon:RefreshThemeTree()
            else
                widget:SetText(tostring(entry.threshold))
            end
        end)
        group:AddChild(thresholdBox)

        local colorPicker = AceGUI:Create("ColorPicker")
        colorPicker:SetLabel(L.TextColor)
        colorPicker:SetHasAlpha(true)
        colorPicker:SetRelativeWidth(0.35)
        local r, g, b, a = Addon.HexToRGBA(entry.color)
        colorPicker:SetColor(r, g, b, a)
        colorPicker:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            local color = Addon.RGBAToHex(r, g, b, a)
            Addon:SetTextColorValue(theme, i, color)
        end)
        group:AddChild(colorPicker)

        local removeBtn = AceGUI:Create("Button")
        removeBtn:SetText(L.RemoveThreshold)
        removeBtn:SetRelativeWidth(0.25)
        removeBtn:SetCallback("OnClick", function()
            if Addon:RemoveTextColorEntry(theme, i) then
                Addon:RefreshThemeTree()
            end
        end)
        group:AddChild(removeBtn)

        container:AddChild(group)
        prevThreshold = threshold
    end

    -- default color
    local defaultGroup = AceGUI:Create("InlineGroup")
    defaultGroup:SetTitle(Addon:FormatDefaultColorRange(prevThreshold))
    defaultGroup:SetFullWidth(true)
    defaultGroup:SetLayout("Flow")

    Addon:AddColorPicker(defaultGroup, themeID, 'defaultTextColor', {
        name = L.TextColor,
    })

    container:AddChild(defaultGroup)
end

local function buildManagementOptions(container, themeID)
    container:SetLayout("Flow")

    -- rename (only for non-default themes)
    if themeID ~= "default" then
        local renameBox = AceGUI:Create("EditBox")
        renameBox:SetLabel(L.RenameTheme)
        renameBox:SetFullWidth(true)
        renameBox:SetCallback("OnEnterPressed", function(widget, _, val)
            val = strtrim(val)
            if val ~= '' then
                Addon:SetThemeProperty(themeID, 'displayName', val)
                widget:SetText("")
                Addon:RefreshThemePanel()
            end
        end)
        container:AddChild(renameBox)
    end

    -- reset
    local resetBtn = AceGUI:Create("Button")
    resetBtn:SetText(L.ResetTheme)
    resetBtn:SetFullWidth(true)
    resetBtn:SetCallback("OnClick", function()
        if Addon:ResetTheme(themeID) then
            Addon:RefreshThemeTree()
        end
    end)
    container:AddChild(resetBtn)
end

--------------------------------------------------------------------------------
-- Tree Group Builders
--------------------------------------------------------------------------------

local TREE_ITEMS = {
    { value = "general", text = L.General },
    { value = "text", text = L.Typography },
    { value = "colors", text = L.Colors },
    { value = "manage", text = L.ManageThemes },
}

local TREE_BUILDERS = {
    general = buildGeneralOptions,
    text = buildTextOptions,
    colors = buildColorOptions,
    manage = buildManagementOptions,
}

local activeTree

local function onTreeGroupSelected(container, _, group)
    container:ReleaseChildren()

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")

    local builder = TREE_BUILDERS[group]
    if builder then
        builder(scroll, getSelectedThemeID())
    end

    container:AddChild(scroll)
end

-- Refresh just the tree content (e.g., after a color threshold change)
function Addon:RefreshThemeTree()
    if activeTree then
        local status = activeTree.status or activeTree.localstatus
        local selected = status and status.selected
        onTreeGroupSelected(activeTree, nil, selected or "general")
    end
end

-- Refresh the entire theme panel (e.g., after theme switch/create/delete)
function Addon:RefreshThemePanel()
    if Addon._buildThemePanel then
        Addon._buildThemePanel()
    end
end

--------------------------------------------------------------------------------
-- Main Theme Panel
--------------------------------------------------------------------------------

function Addon:BuildThemePanel(container)
    container:SetLayout("Flow")

    -- title
    local title = AceGUI:Create("Label")
    title:SetText("|cFFFFD100" .. L.Themes .. "|r  -  " .. L.ThemesDesc)
    title:SetFontObject(GameFontNormalLarge)
    title:SetFullWidth(true)
    container:AddChild(title)

    -- toolbar: theme selector + preview button
    local toolbar = AceGUI:Create("SimpleGroup")
    toolbar:SetFullWidth(true)
    toolbar:SetLayout("Flow")

    local themeButton = AceGUI:Create("Button")
    themeButton:SetText(getThemeDisplayName(getSelectedThemeID()))
    themeButton:SetRelativeWidth(0.7)
    themeButton:SetCallback("OnClick", function(widget)
        MenuUtil.CreateContextMenu(widget.frame, generateThemeMenu)
    end)
    toolbar:AddChild(themeButton)

    local previewBtn = AceGUI:Create("Button")
    previewBtn:SetText(L.Preview)
    previewBtn:SetRelativeWidth(0.25)
    previewBtn:SetCallback("OnClick", function()
        self.PreviewDialog:SetTheme(getSelectedThemeID())
    end)
    toolbar:AddChild(previewBtn)

    container:AddChild(toolbar)

    -- tree group for theme options
    local tree = AceGUI:Create("TreeGroup")
    tree:SetTree(TREE_ITEMS)
    tree:SetFullWidth(true)
    tree:SetFullHeight(true)
    tree:SetLayout("Fill")
    tree:SetCallback("OnGroupSelected", onTreeGroupSelected)
    tree:SelectByValue("general")

    activeTree = tree

    container:AddChild(tree)

    -- store rebuild function for RefreshThemePanel
    self._buildThemePanel = function()
        container:ReleaseChildren()
        self:BuildThemePanel(container)
    end
end
