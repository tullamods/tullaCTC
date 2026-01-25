local _, Addon = ...

-- Theme Rules API
-- Rules are evaluated in priority order (lower = first), first match wins

--- @class ThemeRule
--- @field id string Unique rule ID (used to look up settings in profile.rules)
--- @field priority number Priority order (lower values are checked first)
--- @field match fun(cooldown: Cooldown): boolean Function that returns true if the rule applies
--- @field theme? string Fallback theme if not configured in profile.rules
--- @field displayName? string Optional display name for the rule
--- @field builtin? boolean If true, rule defaults to enabled; custom rules default to disabled

local themeRules = {}

--- Registers a theme rule for cooldown styling.
--- Rules are evaluated in priority order (lower = first), first match wins.
--- @param rule ThemeRule Rule definition table
function Addon:RegisterThemeRule(rule)
    assert(type(rule) == "table", "rule must be a table")
    assert(type(rule.id) == "string", "rule.id must be a string")
    assert(type(rule.priority) == "number", "rule.priority must be a number")
    assert(type(rule.match) == "function", "rule.match must be a function")
    assert(rule.theme == nil or type(rule.theme) == "string", "rule.theme must be a string or nil")
    assert(rule.displayName == nil or type(rule.displayName) == "string", "rule.displayName must be a string or nil")

    for _, r in pairs(themeRules) do
        assert(r.id ~= rule.id, format("a rule with id %q already exists", rule.id))
    end

    -- insert at sorted position
    local index = #themeRules + 1
    for i, r in ipairs(themeRules) do
        if rule.priority < r.priority then
            index = i
            break
        end
    end
    table.insert(themeRules, index, rule)
end

--- @param id string Unique identifier of the rule to remove
function Addon:UnregisterThemeRule(id)
    assert(type(id) == "string", "id must be a string")

    for i, r in pairs(themeRules) do
        if r.id == id then
            table.remove(themeRules, i)
            return
        end
    end
end

--- Checks if a rule is enabled.
--- Built-in rules default to enabled, custom rules default to disabled.
--- @param rule ThemeRule The rule to check
--- @return boolean enabled Whether the rule is enabled
function Addon:IsRuleEnabled(rule)
    local settings = self.db and self.db.profile.rules[rule.id]
    if settings and settings.enabled ~= nil then
        return settings.enabled
    end
    -- Default: builtin rules are enabled, custom rules are disabled
    return rule.builtin == true
end

--- Gets the theme name for a cooldown by evaluating registered rules.
--- @param cooldown Cooldown The cooldown frame to evaluate
--- @return string themeName The name of the matching theme, or "default" if no rules match
function Addon:GetThemeName(cooldown)
    for _, rule in ipairs(themeRules) do
        if self:IsRuleEnabled(rule) and rule.match(cooldown) then
            -- Look up theme from profile, fall back to rule.theme or "default"
            local settings = self.db and self.db.profile.rules[rule.id]
            local theme = settings and settings.theme
            return theme or rule.theme or "default"
        end
    end

    return "default"
end

--- Iterates over all registered theme rules in priority order.
--- @return fun(): ThemeRule? iterator
function Addon:IterateThemeRules()
    local i = 0
    return function()
        i = i + 1
        return themeRules[i]
    end
end

-- Duration Provider API
-- Providers are evaluated in priority order (lower = first), first match wins
--- @class DurationProvider
--- @field id string Unique identifier for the provider
--- @field priority number Priority order (lower values are checked first)
--- @field handle fun(cooldown: Cooldown): (success: boolean, duration: DurationObject?)
--- @field displayName? string Optional display name for the provider

local durationProviders = {}

--- Registers a duration provider for cooldown timing.
--- Providers are evaluated in priority order (lower = first), first match wins.
--- @param provider DurationProvider Provider definition table
function Addon:RegisterDurationProvider(provider)
    assert(type(provider) == "table", "provider must be a table")
    assert(type(provider.id) == "string", "provider.id must be a string")
    assert(type(provider.priority) == "number", "provider.priority must be a number")
    assert(type(provider.handle) == "function", "provider.handle must be a function")
    assert(provider.displayName == nil or type(provider.displayName) == "string", "provider.displayName must be a string or nil")

    for _, p in ipairs(durationProviders) do
        assert(p.id ~= provider.id, format("a provider with id %q already exists", provider.id))
    end

    -- insert at sorted position
    local pos = #durationProviders + 1
    for i, p in ipairs(durationProviders) do
        if provider.priority < p.priority then
            pos = i
            break
        end
    end
    table.insert(durationProviders, pos, provider)
end

--- Unregisters a previously registered duration provider.
--- @param id string Unique identifier of the provider to remove
function Addon:UnregisterDurationProvider(id)
    assert(type(id) == "string", "id must be a string")

    for i, p in ipairs(durationProviders) do
        if p.id == id then
            table.remove(durationProviders, i)
            return
        end
    end
end

--- Gets the duration for a cooldown by evaluating registered providers.
--- @param cooldown Cooldown The cooldown frame to evaluate
--- @return DurationObject? duration The duration object from the first matching provider, or nil if none match
function Addon:GetDuration(cooldown)
    for _, provider in ipairs(durationProviders) do
        local success, duration = provider.handle(cooldown)
        if success then
            return duration
        end
    end

    return nil
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Creates a match function that checks if a cooldown's frame name matches any of the given patterns.
--- Walks up the parent hierarchy to find a named frame.
--- @param ... string Lua patterns to match against the frame name
--- @return fun(frame: Region): boolean matcher Function that returns true if the frame name matches any pattern
function Addon.MatchName(...)
    local patterns = {...}

    return function(region)
        local f = region
        local name

        while f do
            name = f:GetName()
            if name then
                break
            end
            f = f:GetParent()
        end

        if name then
            for i = 1, #patterns do
                if name:match(patterns[i]) then
                    return true
                end
            end
        end

        return false
    end
end

function Addon.GetActionID(cooldown)
    local parent = cooldown:GetParent()
    if parent then
        return parent.action or parent:GetAttribute("action")
    end
end

function Addon.GetSpellID(cooldown)
    local parent = cooldown:GetParent()
    if parent then
        return parent.spell or parent:GetAttribute("spell")
    end
end

--------------------------------------------------------------------------------
-- Builtin Duration Providers
--------------------------------------------------------------------------------

Addon:RegisterDurationProvider {
    id = "forbid",
    priority = 0,
    handle = function(cooldown)
        return cooldown:IsForbidden()
    end
}

Addon:RegisterDurationProvider {
    id = "action",
    priority = 100,
    handle = function(cooldown)
        local actionID = Addon.GetActionID(cooldown)
        if actionID then
            local key = cooldown:GetParentKey()

            if key == "chargeCooldown" then
                return true, C_ActionBar.GetActionChargeDuration(actionID)
            end

            if key == "lossOfControlCooldown" then
                return true, C_ActionBar.GetActionLossOfControlCooldownDuration(actionID)
            end

            return true, C_ActionBar.GetActionCooldownDuration(actionID)
        end

        return false
    end
}

Addon:RegisterDurationProvider {
    id = "spell",
    priority = 200,
    handle = function(cooldown)
        local spellID = Addon.GetSpellID(cooldown)
        if spellID then
            local key = cooldown:GetParentKey()

            if key == "chargeCooldown" then
                return true, C_Spell.GetSpellChargeDuration(spellID)
            end

            if key == "lossOfControlCooldown" then
                return true, C_Spell.GetSpellLossOfControlCooldownDuration(spellID)
            end

            return true, C_Spell.GetSpellCooldownDuration(spellID)
        end

        return false
    end
}
