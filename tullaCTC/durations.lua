-- Default duration provider config
-- These basically do a bit of introspection in order to try and generate a
-- duration object for a cooldown
--
-- handler functions all have the signature of
-- function(cooldown: Cooldown): (success: boolean, duration?: DurationObject)

local _, Addon = ...

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
