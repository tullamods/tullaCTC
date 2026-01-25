# TullaCTC - Cooldown Text Customizer

Customizes the built in Blizzard Cooldown Count text. Works in World of Warcraft
v12.0.x. Classic versions are unsupported.

## FAQ

### How Complete is the Addon?

I'd say its in a beta/alpha state.

### Where's the GUI?

`/tullaCTC` or `/tctc`

NOTE: The GUI is currently an automated translation of OmniCC's GUI. It needs
a bit of work.

### What are the limitations?

You can change the initial font, anchor, and conditional colors of any cooldown
that tullaCTC can retrieve a Duration object about. Providers can be defined
using the following API method:

```lua
-- returns: isMatch, duration object
tullaCTC:RegisterDurationProvider {
    id = "action",
    priority = 100,
    handle = function(cooldown)
        local actionID = tullaCTC.GetActionID(cooldown)
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
```

tullaCTC will always first try to retrieve information by composing it from
set cooldown, but only works when the information is not secret. Because of this,
the addon doesn't quite work for every cooldown scenario.

The following things cannot be done based upon cooldown durations at the moment

- Resizing text
- Formatting durations differently (ex, showing tenths of seconds under 5s).
  It is possible to set the threshold for MM:SS at least

Additionally, because I cannot retrieve the duration of a cooldown, we must
instead rely on a global loop to refresh the apperance of cooldowns. This is
much less efficient than the prior tullaCTC verison, but shouldn't be awful.

### How do I define new rules?

Here's the API. I'll likely make a text pattern option available in the GUI at
some point:

```lua
tullaCTC:RegisterThemeRule {
    id = "blizzard_action",
    priority = 100,
    displayName = "Action Bars",
    -- just a convieneence
    match = tullaCTC.MatchName(
        "^ActionButton%d+",
        "^MultiBarBottomLeftButton%d+",
        "^MultiBarBottomRightButton%d+",
        "^MultiBarRightButton%d+",
        "^MultiBarLeftButton%d+",
        "^MultiBar5Button%d+",
        "^MultiBar6Button%d+",
        "^MultiBar7Button%d+"
    )
}
```

```lua
tullaCTC:RegisterThemeRule {
    id = "blizzard_action_recharging",
    priority = 100,
    displayName = "Action Bars (Recharging)",
    match = function(cooldown)
        return cooldown:GetParent().action
           and cooldown:GetParentKey() == "chargeCooldown
    end
}
```
