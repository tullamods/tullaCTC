local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

local function getThemeValues()
    local values = {}
    local themes = tullaCTC.db.profile.themes
    for id, theme in pairs(themes) do
        if id ~= '**' then
            values[id] = theme.displayName or id
        end
    end
    return values
end

local function getRuleSettings(ruleId)
    return tullaCTC.db.profile.rules[ruleId]
end

local function createRuleOptions(rule, order)
    return {
        type = 'group',
        name = rule.displayName or rule.id,
        order = order,
        inline = true,
        args = {
            enabled = {
                type = 'toggle',
                name = L.RuleEnabled,
                desc = L.RuleEnabledDesc,
                order = 1,
                width = 0.6,
                get = function()
                    return tullaCTC:IsRuleEnabled(rule)
                end,
                set = function(_, value)
                    local settings = getRuleSettings(rule.id)
                    settings.enabled = value
                    tullaCTC:Refresh()
                end
            },
            theme = {
                type = 'select',
                name = L.RuleTheme,
                desc = L.RuleThemeDesc,
                order = 2,
                width = 1.2,
                disabled = function()
                    return not tullaCTC:IsRuleEnabled(rule)
                end,
                values = getThemeValues,
                get = function()
                    local settings = getRuleSettings(rule.id)
                    return settings.theme or "default"
                end,
                set = function(_, value)
                    local settings = getRuleSettings(rule.id)
                    settings.theme = value
                    tullaCTC:Refresh()
                end
            }
        }
    }
end

local RuleOptions = {
    type = 'group',
    name = L.Rules,
    args = {
        description = {
            type = 'description',
            name = L.RulesDesc,
            order = 0
        }
    }
}

function Addon:RefreshRuleOptions()
    for key in pairs(RuleOptions.args) do
        if key:match('^rule_') then
            RuleOptions.args[key] = nil
        end
    end

    local order = 100
    for rule in tullaCTC:IterateThemeRules() do
        local key = 'rule_' .. rule.id
        RuleOptions.args[key] = createRuleOptions(rule, order)
        order = order + 1
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("tullaCTC")
end

Addon:RefreshRuleOptions()
Addon.RuleOptions = RuleOptions
