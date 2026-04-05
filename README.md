# TullaCTC - Cooldown Text Customizer

tullaCTC is a World of Warcraft addon that provides additional options for
theming cooldowns. It is built to work with the new secrets APIs that were
introduced in of World of Warcraft v12.0.0 (Midnight). With it, you can do
things like:

- Show cooldown counts on everything
- Change the font and color of cooldown text
- Show text in red when under 5s
- Show tenths of seconds
- Hide cooldown spirals

The configuration UI can be brought up via `/tullaCTC`

### Themes & Rules

You can customize cooldown appearances for different parts of the UI via creating themes and then asigning them to different parts of the UI via the rules panel. tullaCTC comes with a bunch of builtin rules for
different parts of the UI, as well as an API to add in additional ones:

```lua
-- Use simple name matching
tullaCTC:RegisterRule {
    id = "blizzard_action",
    priority = 100,
    displayName = "Action Buttons",
    match = {
        "^ActionButton%d+",
        "^MultiBarBottomLeftButton%d+",
        "^MultiBarBottomRightButton%d+",
        "^MultiBarRightButton%d+",
        "^MultiBarLeftButton%d+",
        "^MultiBar5Button%d+",
        "^MultiBar6Button%d+",
        "^MultiBar7Button%d+"
    }
}
```

```lua
-- Or provide a predicate function
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

### OmniCC Feature Comparison

With World of Warcraft v12.0.5, tullaCTC can do just about everything that
OmniCC could do, except:

- *Min Size*
- *Max Duration* (though you can replicate this via setting a transparent text color above a duration)
- *Conditional Scaling*
- *Finish Effects*
