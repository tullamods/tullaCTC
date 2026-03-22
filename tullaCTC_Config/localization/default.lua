-- tullaCTC configuration localization - English
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'enUS', true)

-- Section headers
L.CooldownAppearance = 'Cooldown Appearance'
L.CountdownText = 'Countdown Text'
L.CountdownTextColors = 'Countdown Text Colors'
L.TextFont = 'Text Font'
L.TextPosition = 'Text Position'
L.TextShadow = 'Text Shadow'

-- Theme management
L.Themes = 'Themes'
L.SelectTheme = 'Theme'
L.NewTheme = 'New Theme'
L.CopyTheme = 'Copy'
L.RenameTheme = 'Rename'
L.ResetTheme = 'Reset'
L.DeleteTheme = DELETE
L.EnterThemeName = 'Enter a name for the new theme:'
L.DeleteThemeConfirm = 'Are you sure you want to delete "%s"?'
L.Preview = PREVIEW

-- Theme settings
L.ThemeEnabled = 'Enable Theme'
L.ThemeEnabledDesc = 'Apply this theme to matching cooldowns'
L.ThemeCooldownDesc = 'Customize cooldown animation and swipe settings'
L.ThemeTextDesc = 'Customize countdown text appearance and formatting'

-- Cooldown display options
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
L.UseAuraDisplayTime = 'Aura Duration Rounding'
L.UseAuraDisplayTimeDesc = 'Control how aura durations are rounded. Always rounds down, Never rounds up'

-- Countdown text options
L.MinDuration = 'Minimum Duration'
L.MinDurationDesc = 'How long, in seconds, a cooldown must be to display countdown text'
L.TenthsThreshold = 'Tenths Threshold'
L.TenthsThresholdDesc = 'Show tenths of seconds when the cooldown remaining is below this value'
L.AbbrevThreshold = 'MM:SS Threshold'
L.AbbrevThresholdDesc = 'How long, in seconds, before cooldown text switches to MM:SS format (e.g., "1:30" instead of "90")'

-- Font options
L.FontFace = 'Font'
L.FontOutline = 'Font Outline'
L.FontSize = 'Font Size'
L.Outline_NONE = NONE
L.Outline_OUTLINE = 'Thin'
L.Outline_OUTLINEMONOCHROME = 'Monochrome'
L.Outline_THICKOUTLINE = 'Thick'

-- Position / shadow
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
L.HorizontalOffset = 'Horizontal Offset'
L.VerticalOffset = 'Vertical Offset'
L.TextShadowColor = COLOR

-- Tri-state values
L.DrawState_default = 'Default'
L.DrawState_always = 'Always'
L.DrawState_never = 'Never'

-- Color threshold UI
L.AddColorThreshold = 'Add Color Threshold'
L.Duration = 'Duration'
L.TextColor = 'Text Color'
L.ColorRangeDays = '%d day(s)'
L.ColorRangeHours = '%d hour(s)'
L.ColorRangeMinutes = '%d minute(s)'
L.ColorRangeSeconds = '%d second(s)'
L.ColorRangeAbove = 'Above %s'
L.ColorRangeOrLess = '%s or less'
L.ColorRangeTo = '%s to %s'
L.ColorRangeAll = 'All durations'

-- Rules
L.Rules = 'Rules'

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

-- Profiles
L.Profile = 'Profile'
L.NewProfile = 'New Profile'
L.DuplicateProfile = 'Copy'
L.ResetProfile = 'Reset'
L.DeleteProfile = 'Delete'
L.EnterNewProfileName = 'Enter a name for the new profile:'
