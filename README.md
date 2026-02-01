# TullaCTC - Cooldown Text Customizer

## NOTE: This addon is a bit of a work in progress and needs more testing.

tullaCTC is a World of Warcraft addon that provides additional options for theming Blizzard's builtin cooldown count text.
It is built to work with the new secrets APIs that are a part of World of Warcraft Midnight (and probably later expansions).

The configuration UI can be brought up via `/tullaCTC`

### OmniCC Feature Comparison

| Feature | Status | Notes |
| ------- | ------ | ----- |
| Enable Text | Implemented | Force hide, show, or default (let the rest of the UI handle it) |
| Font | Implemented | Face, Size, Outline, Shadow |
| Timer Offset | Not Implemented | tullaCTC cannot modify the actual duration being displayed |
| Scale Text | Not Implemented | TBD |
| Min Size | Not Implemented | I may not implement this one, as tullaCTC's rules engine is a bit better to work with |
| Min Duration | Implemented | Automatic GCD filtering isn't implemented, but base duration filtering is |
| Max Duration | Not Implemented | As a workaround, add a new color threshold entry the duration you don't want to see and make the color transparent. |
| Tenths of Seconds | Not Implemented | There's not enough presentational options available for me to do this quite yet, I think |
| MM:SS Duration | Implemented | |
| Text Position | Implemented | |
| Cooldown Opacity | Not Implemented | TBD |
| Conditional Coloring | Implemented | Ex, red when soon to expire |
| Conditional Scaling  | Not Implemented | Ex, slightly smaller when a longer duration. APIs are not there to be able to implement this |
| Finish Effects | Not Implemented | TBD |

Additionally, tullaCTC has to rely upon a simple periodic loop to handle updates.
OmniCC, being able to know the actual duration of a cooldown, was able to schedule things a bit more smartly. I don't think
this will have a super major impact on CPU usage, but it's going to be a bit more constant than OmniCC was.

### The Duration Provider API

tullaCTC needs to be able to retrieve a [duration object](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject) in order to implement
conditional coloring. When a cooldown is initially started, the addon will try and create one from the cooldown information itself, but
that'll only work if the information is not secret. To work around this, the addon implements a duration provider API:

```lua
-- handle should be
-- function(cooldown: Cooldown): (success: boolean, duration?: DurationObject)
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

This is one of the reasons that tullaCTC is tullaCTC and not OmniCTC. tullaCTC will work on a lot of things, but not all things.

### The Rules API

tullaCTC has a Lua API to define cooldown groups and let users map them to themes.
You can use either pattern matching based upon ancestor names:

```lua
tullaCTC:RegisterRule {
    id = "blizzard_action",
    priority = 100,
    displayName = "Action Buttons",
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

Or use a predicate function that takes the cooldown itself as the first argument.

```lua
-- Allows for styling
tullaCTC:RegisterRule {
    id = "blizzard_action_recharging",
    priority = 110,
    displayName = "Action Buttons - Charge",
    match = function(cooldown)
        local parent = cooldown:GetParent()
        return parent
           and parent.action
           and cooldown:GetParentKey() == "chargeCooldown"
    end
}
```
