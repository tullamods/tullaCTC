-- tullaCTC configuration localization - English
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'enUS', true)

L.Anchor = 'Anchor'
L.Anchor_BOTTOM = 'Bottom'
L.Anchor_BOTTOMLEFT = 'Bottom Left'
L.Anchor_BOTTOMRIGHT = 'Bottom Right'
L.Anchor_CENTER = 'Center'
L.Anchor_LEFT = 'Left'
L.Anchor_RIGHT = 'Right'
L.Anchor_TOP = 'Top'
L.Anchor_TOPLEFT = 'Top Left'
L.Anchor_TOPRIGHT = 'Top Right'
L.Colors = 'Colors'
L.ColorsDesc = 'Configure text colors based on remaining cooldown time'
L.ColorsDescription = 'Set the color and duration threshold for each time range. Text will use the color for durations up to the threshold.'
L.CooldownText = 'Cooldown Text'
L.Duration = 'Duration'
L.FontFace = 'Font Face'
L.FontOutline = 'Font Outline'
L.FontSize = 'Font Size'
L.General = GENERAL
L.HorizontalOffset = 'Horizontal Offset'
L.MinDuration = 'Minimum Duration'
L.MinDurationDesc = 'How long, in seconds, a cooldown must be to display countdown text'
L.AbbrevThreshold = 'Abbreviation Threshold'
L.AbbrevThresholdDesc = 'How long, in seconds, before cooldown text switches to abbreviated format (e.g., "1m" instead of "60")'
L.Outline_NONE = NONE
L.Outline_OUTLINE = 'Thin'
L.Outline_OUTLINEMONOCHROME = 'Monochrome'
L.Outline_THICKOUTLINE = 'Thick'
L.Preview = PREVIEW
L.TextColor = 'Text Color'
L.TextFont = 'Text Font'
L.TextPosition = 'Text Position'
L.TextShadow = 'Text Shadow'
L.TextShadowColor = COLOR
L.Themes = 'Themes'
L.CreateTheme = 'Create Theme'
L.CreateThemeDesc = 'Creates a new theme with the specified name'
L.DeleteTheme = DELETE
L.DeleteThemeDesc = 'Deletes the selected theme'
L.CopyTheme = 'Copy Theme'
L.CopyThemeDesc = 'Make a copy of the current theme'
L.ResetTheme = 'Reset'
L.ResetThemeDesc = 'Resets current theme to default values'
L.RenameTheme = 'Rename'
L.RenameThemeDesc = 'Rename the selected theme'
L.SelectTheme = 'Theme'
L.ManageThemes = 'Themes'
L.Threshold = 'Duration (Seconds)'
L.ThresholdDesc = 'Duration threshold for this color range'
L.Typography = 'Typography'
L.TypographyDesc = 'Configure font and text appearance'
L.VerticalOffset = 'Vertical Offset'
L.UseAuraDisplayTime = 'Use Aura Duration Display Time'
L.UseAuraDisplayTimeDesc = 'This setting effectively controls duration rounding. Always will round down. Never will round up'

-- Color threshold UI
L.AddColorThreshold = 'Add Color Threshold'
L.NewThresholdValue = 'Threshold (seconds)'
L.NewThresholdValueDesc = "Enter threshold in seconds (e.g., 5, 60, 3600)"
L.RemoveThreshold = 'Remove'
L.RemoveThresholdConfirm = 'Remove this color threshold?'
L.ColorRangeDays = '%d day(s)'
L.ColorRangeHours = '%d hour(s)'
L.ColorRangeMinutes = '%d minute(s)'
L.ColorRangeSeconds = '%d second(s)'
L.ColorRangeAbove = 'Above %s'
L.ColorRangeOrLess = '%s or less'
L.ColorRangeTo = '%s to %s'
L.ColorRangeAll = 'All durations'

-- Theme settings
L.ThemeEnabled = 'Enable Theme'
L.ThemeEnabledDesc = 'Apply this theme to matching cooldowns'
L.ThemeText = 'Style Countdown Text'
L.ThemeTextDesc = 'Apply text styling to cooldown counts'
L.ThemeCooldown = 'Style Cooldown Frames'
L.ThemeCooldownDesc = 'Apply cooldown frame specific styling options'

-- Cooldown display options
L.Cooldown = 'Cooldown'
L.CooldownDesc = 'Configure cooldown animation settings'
L.DrawText = 'Show Text'
L.DrawTextDesc = 'Control countdown text visibility'
L.DrawSwipe = 'Show Swipe'
L.DrawSwipeDesc = 'Control the radial swipe animation'
L.DrawEdge = 'Show Edge'
L.DrawEdgeDesc = 'Control the bright edge on the swipe'
L.DrawBling = 'Show Bling'
L.DrawBlingDesc = 'Control the flash effect when cooldown finishes'
L.Reverse = 'Reverse'
L.ReverseDesc = 'Reverse the swipe direction'
L.SwipeColor = 'Swipe Color'
L.SwipeColorDesc = 'Override the color of the cooldown swipe animation'
L.ThemeSwipeColor = 'Override Swipe Color'

-- Tri-state values
L.DrawState_default = 'Default'
L.DrawState_always = 'Always'
L.DrawState_never = 'Never'

-- Rules
L.Rules = 'Rules'
L.RulesDesc = 'Configure which theme to apply to different UI elements'
L.RuleEnabled = 'Enabled'
L.RuleEnabledDesc = 'Enable or disable this rule'
L.RuleTheme = 'Theme'
L.RuleThemeDesc = 'Select which theme to apply when this rule matches'

-- Builtin Theme Names
L.Theme_default = DEFAULT
L.Theme_disable = DISABLE
L.Theme_none= NONE

-- Builtin Rule Names
L.Rule_action = 'Action Buttons'
L.Rule_action_charge = 'Action Buttons - Recharging'
L.Rule_action_loc = 'Action Buttons - Loss of Control'
L.Rule_blizzard_cdm_essential = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_ESSENTIAL_COOLDOWNS)
L.Rule_blizzard_cdm_utility = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_UTILITY_COOLDOWNS)
L.Rule_blizzard_cdm_buff_icons = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_TRACKED_BUFFS)
L.Rule_blizzard_cdm_buff_bars = strjoin(' - ', COOLDOWN_VIEWER_LABEL, HUD_EDIT_MODE_SYSTEM_TRACKED_BUFF_BARS)
L.Rule_blizzard_petbar = HUD_EDIT_MODE_PET_ACTION_BAR_LABEL
L.Rule_blizzard_stancebar = HUD_EDIT_MODE_STANCE_BAR_LABEL
L.Rule_blizzard_possessbar = HUD_EDIT_MODE_POSSESS_ACTION_BAR_LABEL
L.Rule_blizzard_extrabar = HUD_EDIT_MODE_EXTRA_ABILITIES_LABEL
L.Rule_blizzard_zone = 'Zone Ability'
L.Rule_blizzard_container = HUD_EDIT_MODE_BAGS_LABEL
L.Rule_blizzard_nameplates = 'Nameplates'
L.Rule_blizzard_target = HUD_EDIT_MODE_TARGET_FRAME_LABEL
L.Rule_blizzard_focus = HUD_EDIT_MODE_FOCUS_FRAME_LABEL
L.Rule_blizzard_pet = HUD_EDIT_MODE_PET_FRAME_LABEL
L.Rule_blizzard_party = HUD_EDIT_MODE_PARTY_FRAMES_LABEL
L.Rule_blizzard_raid = HUD_EDIT_MODE_RAID_FRAMES_LABEL
L.Rule_blizzard_arena = HUD_EDIT_MODE_ARENA_FRAMES_LABEL
L.Rule_blizzard_encounter_timeline = HUD_EDIT_MODE_SYSTEM_ENCOUNTER_TIMELINE
L.Rule_everything = 'Everything Else'
