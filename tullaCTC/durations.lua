-- Default duration provider config
-- These basically do a bit of introspection in order to try and generate a
-- duration object for a cooldown
--
-- handlers all have the signature of
-- function(cooldown: Cooldown): (success: boolean, duration?: DurationObject)

local _, Addon = ...

Addon:RegisterDurationProvider {
    id = "action",
    priority = 100,
    handle = function(cooldown)
        local parent = cooldown:GetParent()

        if parent and type(parent.action) == "number" then
            if parent.chargeCooldown == cooldown then
                return true, C_ActionBar.GetActionChargeDuration(parent.action)
            end

            if parent.lossOfControlCooldown == cooldown then
                return true, C_ActionBar.GetActionLossOfControlCooldownDuration(parent.action)
            end

            return true, C_ActionBar.GetActionCooldownDuration(parent.action)
        end

        return false
    end
}

Addon:RegisterDurationProvider {
    id = "aura",
    priority = 200,
    handle = function(cooldown)
        local parent = cooldown:GetParent()

        if parent and parent.unit and parent.auraInstanceID then
            return true, C_UnitAuras.GetAuraDuration(parent.unit, parent.auraInstanceID)
        end

        return false
    end
}

Addon:RegisterDurationProvider {
    id = "spell",
    priority = 300,
    handle = function(cooldown)
        local parent = cooldown:GetParent()

        if parent and type(parent.spellID) == "number" then
            if parent.chargeCooldown == cooldown then
                return true, C_Spell.GetSpellChargeDuration(parent.spellID)
            end

            if parent.lossOfControlCooldown == cooldown then
                return true, C_Spell.GetSpellLossOfControlCooldownDuration(parent.spellID)
            end

            return true, C_Spell.GetSpellCooldownDuration(parent.spellID)
        end

        return false
    end
}