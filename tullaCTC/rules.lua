local _, Addon = ...

--------------------------------------------------------------------------------
-- Built-in Theme Rules
-- Match is simply a predicate function that takes a single argument (cooldown)
--
-- TODO: Localize all of the theme names
--------------------------------------------------------------------------------

-- Action Bars (Blizzard)
Addon:RegisterThemeRule {
    id = "blizzard_action",
    builtin = true,
    priority = 100,
    displayName = "Action Bars",
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and cooldown:GetParentKey() == "cooldown"
    end
}

Addon:RegisterThemeRule {
    id = "blizzard_action_recharging",
    builtin = true,
    priority = 110,
    displayName = "Action Bars (Recharging)",
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and cooldown:GetParentKey() == "chargeCooldown"
    end
}

-- Pet Action Bar
Addon:RegisterThemeRule {
    id = "blizzard_pet",
    builtin = true,
    priority = 200,
    displayName = "Pet Bar",
    match = Addon.MatchName("^PetActionButton%d+")
}

-- Stance/Shapeshift Bar
Addon:RegisterThemeRule {
    id = "blizzard_stance",
    builtin = true,
    priority = 300,
    displayName = "Stance Bar",
    match = Addon.MatchName("^StanceButton%d+")
}

-- Possess Bar
Addon:RegisterThemeRule {
    id = "blizzard_possess",
    builtin = true,
    priority = 400,
    displayName = "Possess Bar",
    match = Addon.MatchName("^PossessButton%d+")
}

-- Extra Action Button
Addon:RegisterThemeRule {
    id = "blizzard_extra",
    builtin = true,
    priority = 500,
    displayName = "Extra Action",
    match = Addon.MatchName("^ExtraActionButton%d+")
}

-- Zone Ability Button
Addon:RegisterThemeRule {
    id = "blizzard_zone",
    builtin = true,
    priority = 600,
    displayName = "Zone Ability",
    match = Addon.MatchName("^ZoneAbilityFrame")
}

-- Aura Buttons (Buffs/Debuffs)
Addon:RegisterThemeRule {
    id = "blizzard_target",
    builtin = true,
    priority = 700,
    displayName = "Target Frame",
    match = Addon.MatchName("^TargetFrame")
}

Addon:RegisterThemeRule {
    id = "blizzard_container",
    builtin = true,
    priority = 800,
    displayName = "Inventory",
    match = Addon.MatchName("^ContainerFrame")
}

-- Catch-all fallback (lowest priority, matches everything)
-- This rule technically does not need to be defined, but is implemented to
-- make it a bit easier for end users change the fallback theme
Addon:RegisterThemeRule {
    id = "fallback",
    builtin = true,
    priority = math.huge,
    displayName = "Everything Else",
    match = function() return true end
}
