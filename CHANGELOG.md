# tullaCTC Version History

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
