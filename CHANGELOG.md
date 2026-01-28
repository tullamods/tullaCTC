# tullaCTC Version History

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
