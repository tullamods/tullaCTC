local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

local ROW_HEIGHT = 30
local PADDING = Addon.PADDING
local SPACING = Addon.SPACING

StaticPopupDialogs["TULLACTC_NEW_RULE_THEME"] = {
    text = L.EnterThemeName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data.ruleName)
        self.EditBox:HighlightText()
    end,
    OnAccept = function(self, data)
        local name = self.EditBox:GetText():trim()
        if name ~= "" and not Addon:HasTheme("custom_" .. name) then
            local newID = Addon:CreateTheme(name)
            if newID then
                data.settings.theme = newID
                tullaCTC:Refresh()
                Addon:OpenToThemesTab(newID)
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

local function buildThemeDropdownMenu(_, rootDescription, settings, ruleName)
    for _, id in ipairs(Addon:GetSortedThemeIDs()) do
        rootDescription:CreateRadio(Addon.GetThemeDisplayName(id),
            function() return settings.theme == id end,
            function()
                settings.theme = id
                tullaCTC:Refresh()
            end)
    end

    rootDescription:CreateDivider()

    rootDescription:CreateButton(L.NewTheme, function()
        StaticPopup_Show("TULLACTC_NEW_RULE_THEME", nil, nil, {
            ruleName = ruleName,
            settings = settings,
        })
    end)
end

local function buildRuleRow(rowFrame, rule, settings)
    local ruleName = rawget(L, "Rule_" .. rule.id) or rule.displayName or rule.id
    local enabled = tullaCTC:IsRuleEnabled(rule)

    if not rowFrame._initialized then
        rowFrame._initialized = true

        local cb = CreateFrame("CheckButton", nil, rowFrame, "UICheckButtonTemplate")
        cb:SetSize(ROW_HEIGHT - 4, ROW_HEIGHT - 4)
        cb:SetPoint("LEFT", rowFrame, "LEFT", 0, 0)
        cb.Text:SetFontObject(GameFontNormal)
        cb.Text:SetPoint("LEFT", cb, "RIGHT", PADDING / 2, 0)
        rowFrame._cb = cb

        local dd = CreateFrame("DropdownButton", nil, rowFrame, "WowStyle1DropdownTemplate")
        dd:SetPoint("LEFT", rowFrame, "CENTER", PADDING, 0)
        dd:SetPoint("RIGHT", rowFrame, "RIGHT", 0, 0)
        dd:SetHeight(ROW_HEIGHT - 4)
        rowFrame._dd = dd
    end

    local cb = rowFrame._cb
    local dd = rowFrame._dd

    cb.Text:SetText(ruleName)
    cb:SetChecked(enabled)
    cb:SetScript("OnClick", function(self)
        settings.enabled = self:GetChecked()
        dd:SetEnabled(settings.enabled)
        tullaCTC:Refresh()
    end)

    dd:SetEnabled(enabled)
    dd:SetupMenu(function(self, rootDescription)
        buildThemeDropdownMenu(self, rootDescription, settings, ruleName)
    end)
end

function Addon:BuildRulesPanel(container)
    local header = Addon:CreatePanelHeader(container, L.Rules)

    local scrollBox = CreateFrame("Frame", nil, container, "WowScrollBoxList")
    local scrollBar = CreateFrame("EventFrame", nil, container, "MinimalScrollBar")

    scrollBox:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    scrollBox:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -16, 0)
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 2, -20)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 2, 20)

    local view = CreateScrollBoxListLinearView(PADDING, PADDING, PADDING, PADDING, SPACING)
    view:SetElementExtent(ROW_HEIGHT)
    view:SetElementFactory(function(factory, elementData)
        factory("Frame", function(rowFrame, elementData)
            rowFrame:SetHeight(ROW_HEIGHT)
            buildRuleRow(rowFrame, elementData.rule, elementData.settings)
        end)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

    local function populate()
        local dp = CreateDataProvider()
        for _, rule in tullaCTC:IterateRules() do
            local ruleSettings = tullaCTC.db.profile.rules[rule.id]
            dp:Insert({ rule = rule, settings = ruleSettings })
        end
        scrollBox:SetDataProvider(dp)
    end

    populate()
    self._refreshRulesPanel = populate

    Addon:RegisterCallback("OnThemeListChanged", function()
        populate()
    end, container)
end
