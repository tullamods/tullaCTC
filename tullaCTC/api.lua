local _, Addon = ...

local rules = {}

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

    local match = rule.match
    if type(match) == "table" then
        match = Addon.MatchName(match)
    end

    tinsert(rules, index, {
        id = rule.id,
        priority = rule.priority,
        match = match,
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
-- Helpers
--------------------------------------------------------------------------------

--- Creates a match function that checks if a cooldown's frame name matches any of the given patterns.
--- Walks up the parent hierarchy to find a named frame.
--- @param ... string|table Lua patterns to match against the frame name
--- @return fun(frame: Region): boolean matcher Function that returns true if the frame name matches any pattern
function Addon.MatchName(...)
    local patterns
    if type(...) == "table" then
        patterns = ...
    else
        patterns = { ... }
    end

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
