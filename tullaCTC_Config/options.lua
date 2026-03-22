local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

local PAD = Addon.PAD
local SPACING = Addon.SPACING

local mainFrame
local mainCategory
local themesPanel
local rulesPanel
local activeSelectTab

local function buildThemesPanel(panel)
    if panel._content then panel._content:Hide() end
    local content = CreateFrame("Frame", nil, panel)
    content:SetAllPoints()
    panel._content = content
    Addon:BuildThemePanel(content)
end

local function buildRulesPanel(panel)
    if panel._content then panel._content:Hide() end
    local content = CreateFrame("Frame", nil, panel)
    content:SetAllPoints()
    panel._content = content
    Addon:BuildRulesPanel(content)
end

local function buildCanvas(canvas)
    if canvas._content then canvas._content:Hide() end
    local content = CreateFrame("Frame", nil, canvas)
    content:SetAllPoints()
    canvas._content = content

    local tabBar = CreateFrame("Frame", nil, content)
    tabBar:SetHeight(37)
    tabBar:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -PAD)
    tabBar:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PAD, -PAD)

    local contentArea = CreateFrame("Frame", nil, content)
    contentArea:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -SPACING)
    contentArea:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)

    themesPanel = CreateFrame("Frame", nil, contentArea)
    themesPanel:SetAllPoints()
    rulesPanel = CreateFrame("Frame", nil, contentArea)
    rulesPanel:SetAllPoints()

    buildThemesPanel(themesPanel)
    buildRulesPanel(rulesPanel)

    local allPanels = { themesPanel, rulesPanel }
    local tabLabels = { L.Themes, L.Rules }
    local tabButtons = {}

    local tabDividerLeft = content:CreateTexture(nil, "ARTWORK")
    tabDividerLeft:SetHeight(1)
    tabDividerLeft:SetColorTexture(0.3, 0.3, 0.3, 1)

    local tabDividerRight = content:CreateTexture(nil, "ARTWORK")
    tabDividerRight:SetHeight(1)
    tabDividerRight:SetColorTexture(0.3, 0.3, 0.3, 1)

    local function selectTab(index)
        for i, panel in ipairs(allPanels) do
            panel:SetShown(i == index)
        end
        for i, btn in ipairs(tabButtons) do
            btn:SetSelected(i == index)
        end
        local activeBtn = tabButtons[index]
        tabDividerLeft:ClearAllPoints()
        tabDividerLeft:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, 0)
        tabDividerLeft:SetPoint("TOPRIGHT", activeBtn, "BOTTOMLEFT", 0, 0)
        tabDividerRight:ClearAllPoints()
        tabDividerRight:SetPoint("TOPLEFT", activeBtn, "BOTTOMRIGHT", 0, 0)
        tabDividerRight:SetPoint("TOPRIGHT", tabBar, "BOTTOMRIGHT", 0, 0)
    end

    local prevBtn = nil
    for i, label in ipairs(tabLabels) do
        local btn = CreateFrame("Button", nil, tabBar, "MinimalTabTemplate")
        btn.Text:SetText(label)
        btn:SetWidth(btn.Text:GetStringWidth() + 40)
        if prevBtn then
            btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", 4, 0)
        else
            btn:SetPoint("TOPLEFT", tabBar, "TOPLEFT", 0, 0)
        end
        tabButtons[i] = btn
        btn:SetScript("OnClick", function() selectTab(i) end)
        prevBtn = btn
    end

    local profileDD = Addon:BuildProfileDropdown(tabBar)
    profileDD:SetSize(140, 26)
    profileDD:SetPoint("BOTTOMRIGHT", tabBar, "BOTTOMRIGHT", 0, 2)

    local profileLabel = tabBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    profileLabel:SetText(L.Profile)
    profileLabel:SetPoint("RIGHT", profileDD, "LEFT", -PAD, 0)

    activeSelectTab = selectTab
    selectTab(1)
end

mainFrame = CreateFrame("Frame")
mainFrame.OnRefresh = function(self)
    if not self._built then
        buildCanvas(self)
        self._built = true
    end
end
mainCategory = Settings.RegisterCanvasLayoutCategory(mainFrame, "tullaCTC")
Settings.RegisterAddOnCategory(mainCategory)

function tullaCTC:OpenOptions()
    Settings.OpenToCategory(mainCategory:GetID())
end

function Addon:OpenToThemesTab(themeID)
    tullaCTC:OpenOptions()
    if activeSelectTab then activeSelectTab(1) end
    if themeID then Addon:SelectAndRefreshTheme(themeID) end
end

function Addon:OnProfileChanged()
    if mainFrame then
        buildCanvas(mainFrame)
        mainFrame._built = true
    end
end

tullaCTC.db.RegisterCallback(Addon, 'OnProfileChanged', 'OnProfileChanged')
tullaCTC.db.RegisterCallback(Addon, 'OnProfileCopied', 'OnProfileChanged')
tullaCTC.db.RegisterCallback(Addon, 'OnProfileReset', 'OnProfileChanged')
