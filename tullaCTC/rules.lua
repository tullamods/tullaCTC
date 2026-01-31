local _, Addon = ...

--------------------------------------------------------------------------------
-- Built-in Rules
-- Rules categorize cooldowns; themes are assigned via profile settings
--------------------------------------------------------------------------------

-- Action Buttons
-- TODO: will likely provide a way to combine handlers like these into a single function call for perf
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
    priority = 120,
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and cooldown:GetParentKey() == "lossOfControlCooldown"
    end
}

--------------------------------------------------------------------------------
-- Blizzard Cooldown Manager
--------------------------------------------------------------------------------

-- cooldown manager
Addon:RegisterRule {
    id = "blizzard_cdm_essential",
    displayName = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_ESSENTIAL_COOLDOWNS),
    priority = 200,
    match = Addon.MatchName("^EssentialCooldownViewer")
}

Addon:RegisterRule {
    id = "blizzard_cdm_utility",
    displayName = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_UTILITY_COOLDOWNS),
    priority = 210,
    match = Addon.MatchName("^UtilityCooldownViewer")
}

Addon:RegisterRule {
    id = "blizzard_cdm_buff_icons",
    displayName = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_TRACKED_BUFFS),
    priority = 220,
    match = Addon.MatchName("^BuffIconCooldownViewer")
}

Addon:RegisterRule {
    id = "blizzard_cdm_buff_bars",
    displayName = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_TRACKED_BUFF_BARS),
    priority = 230,
    match = Addon.MatchName("^BuffBarCooldownViewer")
}

--------------------------------------------------------------------------------
-- Secondary Bars
--------------------------------------------------------------------------------

-- Pet Action Bar
Addon:RegisterRule {
    id = "blizzard_pet",
    priority = 300,
    match = Addon.MatchName("^PetActionButton%d+")
}

-- Stance/Shapeshift Bar
Addon:RegisterRule {
    id = "blizzard_stance",
    priority = 310,
    match = Addon.MatchName("^StanceButton%d+")
}

-- Possess Bar
Addon:RegisterRule {
    id = "blizzard_possess",
    priority = 320,
    match = Addon.MatchName("^PossessButton%d+")
}

-- Extra Action Button
Addon:RegisterRule {
    id = "blizzard_extra",
    priority = 330,
    match = Addon.MatchName("^ExtraActionButton%d+")
}

-- Zone Ability Button
Addon:RegisterRule {
    id = "blizzard_zone",
    priority = 340,
    match = Addon.MatchName("^ZoneAbilityFrame")
}

--------------------------------------------------------------------------------
-- Unit Frames
--------------------------------------------------------------------------------

Addon:RegisterRule {
    id = "blizzard_nameplates",
    priority = 400,
    match = Addon.MatchName("^NamePlate%d+")
}

-- Target Frame
Addon:RegisterRule {
    id = "blizzard_target",
    priority = 410,
    match = Addon.MatchName("^TargetFrame")
}

--------------------------------------------------------------------------------
-- Other Stuff
--------------------------------------------------------------------------------

-- Items
Addon:RegisterRule {
    id = "blizzard_container",
    priority = 500,
    match = Addon.MatchName(
        "^ContainerFrame",
        "^PaperDoll"
    )
}

--------------------------------------------------------------------------------
-- ...And the rest!
--------------------------------------------------------------------------------

Addon:RegisterRule {
    id = "everything",
    enabled = true,
    priority = math.huge,
    match = function() return true end
}
