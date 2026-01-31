local _, Addon = ...

local rules = {}
local durationProviders = {}

--------------------------------------------------------------------------------
-- Rules API
--
-- Rules categorize cooldowns into different groups
-- Users can then assign themes to those groups
--------------------------------------------------------------------------------

--- @class Rule
--- @field id string Unique rule ID (used to look up settings in profile.rules)
--- @field priority number Priority order (lower values are checked first)
--- @field match fun(cooldown: Cooldown): boolean Function that returns true if the rule applies
--- @field displayName? string Optional display name for the rule
--- @field enabled? boolean Default enabled state for the rule.

--- Registers a rule for categorizing cooldowns.
--- Rules are evaluated in priority order (lower = first), first match wins.
--- @param rule Rule Rule definition table
function Addon:RegisterRule(rule)
    assert(type(rule) == "table", "rule must be a table")
    assert(type(rule.id) == "string", "rule.id must be a string")
    assert(type(rule.priority) == "number", "rule.priority must be a number")
    assert(rule.match ~= nil, "rule.match is required")
    assert(rule.displayName == nil or type(rule.displayName) == "string", "rule.displayName must be a string or nil")

    for _, r in pairs(rules) do
        assert(r.id ~= rule.id, format("a rule with id %q already exists", rule.id))
    end

    -- insert at sorted position
    local index = #rules + 1
    for i, r in ipairs(rules) do
        if rule.priority < r.priority then
            index = i
            break
        end
    end

    tinsert(rules, index, {
        id = rule.id,
        priority = rule.priority,
        match = rule.match,
        displayName = rule.displayName,
        enabled = rule.enabled
    })
end

--- @param id string Unique identifier of the rule to remove
function Addon:UnregisterRule(id)
    assert(type(id) == "string", "id must be a string")

    for i, r in pairs(rules) do
        if r.id == id then
            tremove(rules, i)
            return
        end
    end
end

--- Iterates over all registered rules in priority order.
function Addon:IterateRules()
    return ipairs(rules)
end

-- stateless iterator for active rules (no allocation per call)
local function activeRulesIterator(_, index)
    while true do
        index = index + 1
        local rule = rules[index]
        if not rule then
            return nil
        end
        if Addon:IsRuleEnabled(rule) then
            return index, rule
        end
    end
end

--- Iterates over enabled rules in priority order.
function Addon:IterateActiveRules()
    return activeRulesIterator, nil, 0
end

--------------------------------------------------------------------------------
-- Duration Provider API
--
-- A centralized way to retrieve duration objects from cooldowns
-- We need this in WoW 12.0.X+ because the various Cooldown:SetCooldown methods
-- may contain secret args.
--------------------------------------------------------------------------------

--- @class DurationProvider
--- @field id string Unique identifier for the provider
--- @field priority number Priority order (lower values are checked first)
--- @field handle fun(cooldown: Cooldown): (success: boolean, duration: DurationObject | nil)
--- @field displayName? string Optional display name for the provider

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
        local name

        while region do
            name = region:GetName()
            if name then
                break
            end
            region = region:GetParent()
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

function Addon.GetRegionName(region)
    while region do
        local name = region:GetName()
        if name then
            return name
        end
        region = region:GetParent()
    end
end