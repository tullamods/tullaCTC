# tullaCTC Version History

## v12.1.3

* Update TOCs for World of Warcraft 12.1.0

## v12.1.2

* Added support for World of Warcraft 1.15.9 (Vanilla)

## v12.1.1

* Added support for World of Warcraft 2.5.6 (Burning Crusade Classic)

## v12.1.0

* Added support for World of Warcraft 12.0.7 (Retail PTR)
* Adjusted active cooldown frame handling to hopefully better handle secret frames

## v12.0.10

* Fixed rounding issues for tenths of seconds

## v12.0.9

* Added support for World of Warcraft 5.5.4 (Mists PTR)

## v12.0.8

* Fixed MM:SS calculations
* Disabled smooth scaling on text

## v12.0.7

* Fixed some issues with the new rounding options
* Added a "Show Zero" checkbox for controlling whether or not to show 0 when using the Nearest or Down rounding modes
* Adjusted text format breakpoint values to be settings driven instead of using hardcoded values.

## v12.0.6

* Adjusted scaling defaults for the OmniCC theme
* Better handle percentage cooldowns

## v12.0.5

* tullaCTC now uses the new Cooldown:SetCountdownFormatter API to style cooldowns. Eliminated the need for periodic update handlers.
* Cooldown text is now automatically scaled based upon frame width (will make optional later)
* Removed the durations API
* Replaced the aura display time option with a new rounding option
* Added an OmniCC theme (show text on everything by default)

## v12.0.1

* Adjusted the action button cooldown text workaround so that cooldown text appears above the rest
  of an action button's text, but the cooldown spiral remains below.

## v12.0.0

* Calling this a release
* Revamped the configuration UI and moved to the main settings panel
* Forced action button cooldown text to appear above hotkeys
* Added a tenths of seconds option for the 12.0.5 PTR
* Added a guard to resolve some recursive overflows with ArcUI

## v12.0.0-beta9

* Fixed an error that would occur when calling the `Clear` method on a secret cooldown.

## v12.0.0-beta8

* More minor bugfixes

## v12.0.0-beta7

* Added some fallback behavior to attempt to generate cooldown durations upon refresh
* Added addon specific rules for Grid2 and ArcUI

## v12.0.0-beta6

* Added the focus frame to the default ruleset
* Added reset and version commands (`/tctc reset` and `/tctc version`)
* Generated localization files for all locales.
* Minor bugfixes for nil and secret values

## v12.0.0-beta5

* Added additional rules for unit frames and the encounter timeline
* Adjusted the logic for matching charge coolowns to no longer use GetParentKey()

## v12.0.0-beta4

* Added Use Aura Duration Display Time toggle (Thanks kerristrasz)
* Added the ability to override cooldown swipe colors (mostly useful for the cooldown manager)

## v12.0.0-beta3

* Added nameplate support
* Added additional hooks to enforce cooldown styling preferences
* Overall, the addon should be much more consistent in applying styling

## v12.0.0-beta2

* You'll probably need to reset settings. /run tullaCTCDB = nil; ReloadUI()
* Themes now have an enable option. Unchecking it will cause the theme to do nothing.
* Added individual toggles for styling text and coldown frames
* Added show text, swipe, edge, bling, and reverse state options:
  * Always will force enable the setting
  * Never will force disable the setting
  * Default will leave the setting unchanged
* Added the ability to add and remove additional durations for recoloring text.
* Moved theme management to its own panel. Added the ability to copy, reset, and rename themes
* Setting font size to 0 will now

## v12.0.0-beta1

* Rewrote the addon to reimplement a large amount of OmniCC"s functionality
  while being compatible with the new secrets API.
* NOTE: This is very much a proof of concept at this stage. The GUI in particular
  is a work in progress.
