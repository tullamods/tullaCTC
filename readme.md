# TullaCTC - Cooldown Text Customizer

Color and scales the built in Blizzard cooldown count text based on time remaining, doing the following:

* Timers under five seconds are displayed in red, and made a bit larger
* Timers under a minute are displayed in yellow
* Timers under an hour are displayed in white
* Timers over an hour are displayed in grey, and made a bit smaller

## FAQ

### Can I make changes to the colors? 

Yes, but only via saved varables editing at the moment. Refer to https://github.com/tullamods/tullaCTC/blob/c284ab455c00b9c84cd0c4686c30e932dedb257a/main.lua#L175

### How does this differ from OmniCC or tullaCC?

tullaCTC lets the default UI handle updating cooldown time remaining. OmniCC handles that itself. Because of this, tullaCTC has a much simpler job. Using a simple ten second cooldown as example. Here's what happens:

| Duration | OmniCC      | tullaCTC |
| -------- | ----------- | ----- |
| 10       | Initialize  | Initialize |
| 9        | Update text | Sleep |
| 8        | Update text | Sleep |
| 7        | Update text | Sleep |
| 6        | Update text | Sleep |
| 5        | Update text, color to red, size to 1.5x | Update color to red, size to 1.5x |
| 4        | Update text | Sleep |
| 3        | Update text | Sleep |
| 2        | Update text | Sleep |
| 1        | Update text | Sleep |
| 0        | Stop        | Stop  |

As you can see, OmniCC is updating at every transition point from one number to the next (ex 10 to 9). tullaCTC only needs to update when going from displaying text in yellow to displaying text larger and in red (at the 5 second point). Overall, you can expect tullaCTC to use a lot less CPU time.

### Are there any limitations?

The addon will only work on cooldowns that display the standard Blizzard cooldown text. By default, this is limited to action buttons and inventory slots. If you want to show cooldown text on other things (ex auras), OmniCC is still your best bet.
