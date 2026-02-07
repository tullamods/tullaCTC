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
        return parent and parent.action and parent.cooldown == cooldown
    end
}

Addon:RegisterRule {
    id = "action_charge",
    priority = 110,
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and parent.chargeCooldown == cooldown
    end
}

Addon:RegisterRule {
    id = "action_loc",
    priority = 120,
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent and parent.action and parent.lossOfControlCooldown == cooldown
    end
}

--------------------------------------------------------------------------------
-- Blizzard Cooldown Manager
--------------------------------------------------------------------------------

-- cooldown manager
Addon:RegisterRule {
    id = "blizzard_cdm_essential",
    priority = 200,
    match = Addon.MatchName("^EssentialCooldownViewer")
}

Addon:RegisterRule {
    id = "blizzard_cdm_utility",
    priority = 210,
    match = Addon.MatchName("^UtilityCooldownViewer")
}

Addon:RegisterRule {
    id = "blizzard_cdm_buff_icons",
    priority = 220,
    match = Addon.MatchName("^BuffIconCooldownViewer")
}

Addon:RegisterRule {
    id = "blizzard_cdm_buff_bars",
    priority = 230,
    match = Addon.MatchName("^BuffBarCooldownViewer")
}

--------------------------------------------------------------------------------
-- Secondary Bars
--------------------------------------------------------------------------------

-- Pet Action Bar
Addon:RegisterRule {
    id = "blizzard_petbar",
    priority = 300,
    match = Addon.MatchName("^PetActionButton%d+")
}

-- Stance/Shapeshift Bar
Addon:RegisterRule {
    id = "blizzard_stancebar",
    priority = 310,
    match = Addon.MatchName("^StanceButton%d+")
}

-- Possess Bar
Addon:RegisterRule {
    id = "blizzard_possessbar",
    priority = 320,
    match = Addon.MatchName("^PossessButton%d+")
}

-- Extra Action Button
Addon:RegisterRule {
    id = "blizzard_extrabar",
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

Addon:RegisterRule {
    id = "blizzard_party",
    priority = 410,
    match = Addon.MatchName("^PartyFrame")
}

Addon:RegisterRule {
    id = "blizzard_raid",
    priority = 420,
    match = Addon.MatchName("^CompactRaidGroup")
}

Addon:RegisterRule {
    id = "blizzard_arena",
    priority = 430,
    match = Addon.MatchName("^CompactArenaFrame")
}

Addon:RegisterRule {
    id = "blizzard_target",
    priority = 440,
    match = Addon.MatchName("^TargetFrame")
}

Addon:RegisterRule {
    id = "blizzard_focus",
    priority = 450,
    match = Addon.MatchName("^FocusFrame")
}

Addon:RegisterRule {
    id = "blizzard_pet",
    priority = 460,
    match = Addon.MatchName("^PetFrame")
}

--------------------------------------------------------------------------------
-- Encounter Stuff
--------------------------------------------------------------------------------
---
Addon:RegisterRule {
    id = "blizzard_encounter_timeline",
    priority = 500,
    match = Addon.MatchName("^EncounterTimeline")
}

--------------------------------------------------------------------------------
-- Other Stuff
--------------------------------------------------------------------------------

-- Items
Addon:RegisterRule {
    id = "blizzard_container",
    priority = 600,
    match = Addon.MatchName(
        "^ContainerFrame",
        "^PaperDoll"
    )
}

--------------------------------------------------------------------------------
-- Addons
--------------------------------------------------------------------------------

EventUtil.ContinueOnAddOnLoaded('ArcUI', function()
    Addon:RegisterRule {
        id = "arcui",
        displayName = C_AddOns.GetAddOnMetadata("ArcUI", "Title"),
        priority = 710,
        match = Addon.MatchName("^CDMGroups")
    }
end)

EventUtil.ContinueOnAddOnLoaded('Grid2', function()
    Addon:RegisterRule {
        id = "grid2",
        displayName = C_AddOns.GetAddOnMetadata("Grid2", "Title"),
        priority = 720,
        match = Addon.MatchName("^Grid2Layout")
    }
end)

--------------------------------------------------------------------------------
-- ...And the rest!
--------------------------------------------------------------------------------

Addon:RegisterRule {
    id = "everything",
    enabled = true,
    priority = math.huge,
    match = function() return true end
}
