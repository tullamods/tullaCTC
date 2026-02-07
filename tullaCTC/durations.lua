-- Default duration provider config
-- These basically do a bit of introspection in order to try and generate a
-- duration object for a cooldown
--
-- handlers all have the signature of
-- function(cooldown: Cooldown): (success: boolean, duration?: DurationObject)

local _, Addon = ...

local function findProp(region, ...)
    local keyCount = select('#', ...)
    local maxDepth = 4
    local depth = 0

    while region and depth < maxDepth do
        for i = 1, keyCount do
            local key = select(i, ...)
            local value = region[key]

            if value then
                return value
            end
        end

        region = region:GetParent()
        depth = depth + 1
    end
end

Addon:RegisterDurationProvider {
    id = "blizzard_action",
    priority = 100,
    handle = function(cooldown)
        local parent = cooldown:GetParent()
        if not parent then
            return false
        end

        local action = parent.action
        if not action then
            return false
        end

        if parent.chargeCooldown == cooldown then
            return true, C_ActionBar.GetActionChargeDuration(action)
        end

        if parent.lossOfControlCooldown == cooldown then
            return true, C_ActionBar.GetActionLossOfControlCooldownDuration(action)
        end

        return true, C_ActionBar.GetActionCooldownDuration(action)
    end
}

Addon:RegisterDurationProvider {
    id = "blizzard_aura",
    priority = 200,
    handle = function(cooldown)
        local parent = cooldown:GetParent()
        if not parent then
            return false
        end

        local auraInstanceID = findProp(parent, 'auraInstanceID')
        if not auraInstanceID then
            return false
        end

        local auraInstanceUnit = findProp(parent, 'unitToken', 'unit', 'auraDataUnit')
        if auraInstanceUnit then
            return true, C_UnitAuras.GetAuraDuration(auraInstanceUnit, auraInstanceID)
        end

        return false
    end
}

Addon:RegisterDurationProvider {
    id = "blizzard_spell",
    priority = 300,
    handle = function(cooldown)
        local parent = cooldown:GetParent()
        if not parent then
            return false
        end

        local spellID
        if type(parent.GetSpellID) == 'function' then
            spellID = parent:GetSpellID()
        else
            spellID = parent.spellID
        end

        if not spellID then
            return false
        end

        if parent.chargeCooldown == cooldown then
            return true, C_Spell.GetSpellChargeDuration(spellID)
        end

        if parent.lossOfControlCooldown == cooldown then
            return true, C_Spell.GetSpellLossOfControlCooldownDuration(spellID)
        end

        return true, C_Spell.GetSpellCooldownDuration(spellID)
    end
}
