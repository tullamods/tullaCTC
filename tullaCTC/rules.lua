local _, Addon = ...

--------------------------------------------------------------------------------
-- Built-in Rules
-- Rules categorize cooldowns; themes are assigned via profile settings
--------------------------------------------------------------------------------

-- Action Bars (Blizzard)
Addon:RegisterRule {
    id = "action",
    priority = 100,
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and cooldown:GetParentKey() == "cooldown"
    end
}

Addon:RegisterRule {
    id = "action_charge",
    priority = 110,
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and cooldown:GetParentKey() == "chargeCooldown"
    end
}

Addon:RegisterRule {
    id = "action_loc",
    priority = 110,
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and cooldown:GetParentKey() == "lossOfControlCooldown"
    end
}

-- Pet Action Bar
Addon:RegisterRule {
    id = "blizzard_pet",
    priority = 200,
    match = Addon.MatchName("^PetActionButton%d+")
}

-- Stance/Shapeshift Bar
Addon:RegisterRule {
    id = "blizzard_stance",
    priority = 300,
    match = Addon.MatchName("^StanceButton%d+")
}

-- Possess Bar
Addon:RegisterRule {
    id = "blizzard_possess",
    priority = 400,
    match = Addon.MatchName("^PossessButton%d+")
}

-- Extra Action Button
Addon:RegisterRule {
    id = "blizzard_extra",
    priority = 500,
    match = Addon.MatchName("^ExtraActionButton%d+")
}

-- Zone Ability Button
Addon:RegisterRule {
    id = "blizzard_zone",
    priority = 600,
    match = Addon.MatchName("^ZoneAbilityFrame")
}

-- Target Frame
Addon:RegisterRule {
    id = "blizzard_target",
    priority = 700,
    match = Addon.MatchName("^TargetFrame")
}

-- Inventory Frame
Addon:RegisterRule {
    id = "blizzard_container",
    priority = 800,
    match = Addon.MatchName("^ContainerFrame")
}

-- This rule technically does not need to be defined, but is implemented to
-- make it a bit easier to turn tullaCTC into an allow list
Addon:RegisterRule {
    id = "everything",
    enabled = true,
    priority = math.huge,
    match = function() return true end
}
