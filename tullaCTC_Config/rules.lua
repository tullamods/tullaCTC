local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local AceGUI = LibStub('AceGUI-3.0')
local tullaCTC = _G.tullaCTC

local NEW_THEME_KEY = "__new__"

--------------------------------------------------------------------------------
-- Static Popup Dialogs
--------------------------------------------------------------------------------

StaticPopupDialogs["TULLACTC_NEW_RULE_THEME"] = {
    text = L.EnterThemeName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnShow = function(self, data)
        self.editBox:SetText(data.ruleName)
        self.editBox:HighlightText()
    end,
    OnAccept = function(self, data)
        local name = self.editBox:GetText():trim()
        if name ~= "" and not Addon:HasTheme("custom_" .. name) then
            local newID = Addon:CreateTheme(name)
            if newID then
                data.settings.theme = newID
                tullaCTC:Refresh()
                Addon:RefreshRulesPanel()
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

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function getThemeValues()
    local values = {}
    local order = {}

    for id, theme in pairs(tullaCTC.db.profile.themes) do
        values[id] = theme.displayName or rawget(L, 'Theme_' .. id) or id
        order[#order + 1] = id
    end

    table.sort(order, function(a, b)
        return values[a] < values[b]
    end)

    values[NEW_THEME_KEY] = L.NewTheme
    order[#order + 1] = NEW_THEME_KEY

    return values, order
end

local function getRuleSettings(ruleId)
    return tullaCTC.db.profile.rules[ruleId]
end

--------------------------------------------------------------------------------
-- Rules Panel
--------------------------------------------------------------------------------

function Addon:RefreshRulesPanel()
    if self._buildRulesPanel then
        self._buildRulesPanel()
    end
end

function Addon:BuildRulesPanel(container)
    container:SetLayout("Flow")

    -- title
    local title = AceGUI:Create("Label")
    title:SetText("|cFFFFD100" .. L.Rules .. "|r  -  " .. L.RulesDesc)
    title:SetFontObject(GameFontNormalLarge)
    title:SetFullWidth(true)
    container:AddChild(title)

    -- scrollable rules list
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)

    local themeValues, themeOrder = getThemeValues()

    for _, rule in tullaCTC:IterateRules() do
        local ruleName = rawget(L, "Rule_" .. rule.id) or rule.displayName or rule.id
        local settings = getRuleSettings(rule.id)
        local enabled = tullaCTC:IsRuleEnabled(rule)

        local cb = AceGUI:Create("CheckBox")
        cb:SetLabel(ruleName)
        cb:SetRelativeWidth(0.5)
        cb:SetValue(enabled)

        local dd = AceGUI:Create("Dropdown")
        dd:SetLabel("")
        dd:SetRelativeWidth(0.5)
        dd:SetList(themeValues, themeOrder)
        dd:SetValue(settings.theme or "default")
        dd:SetDisabled(not enabled)

        cb:SetCallback("OnValueChanged", function(_, _, val)
            settings.enabled = val
            dd:SetDisabled(not val)
            tullaCTC:Refresh()
        end)

        dd:SetCallback("OnValueChanged", function(_, _, val)
            if val == NEW_THEME_KEY then
                dd:SetValue(settings.theme or "default")
                StaticPopup_Show("TULLACTC_NEW_RULE_THEME", nil, nil, {
                    ruleName = ruleName,
                    settings = settings,
                })
            else
                settings.theme = val
                tullaCTC:Refresh()
            end
        end)

        scroll:AddChild(cb)
        scroll:AddChild(dd)
    end

    container:AddChild(scroll)

    -- store rebuild function for RefreshRulesPanel
    self._buildRulesPanel = function()
        container:ReleaseChildren()
        self:BuildRulesPanel(container)
    end
end
