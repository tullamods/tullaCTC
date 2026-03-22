-- tullaCTC configuration localization - French
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'frFR')
if not L then return end

-- Section headers
L.CooldownAppearance = 'Apparence de recharge'
L.CountdownText = 'Texte du compte à rebours'
L.CountdownTextColors = 'Couleurs du texte du compte à rebours'
L.TextFont = 'Police du texte'
L.TextPosition = 'Position du texte'
L.TextShadow = 'Ombre du texte'

-- Theme management
L.Themes = 'Thèmes'
L.SelectTheme = 'Thème'
L.NewTheme = 'Nouveau thème'
L.CopyTheme = 'Copier'
L.RenameTheme = 'Renommer'
L.ResetTheme = 'Réinitialiser'
L.EnterThemeName = 'Entrez un nom pour le nouveau thème :'
L.DeleteThemeConfirm = 'Voulez-vous vraiment supprimer « %s » ?'

-- Theme settings
L.ThemeEnabled = 'Activer le thème'
L.ThemeEnabledDesc = 'Appliquer ce thème aux temps de recharge correspondants'
L.ThemeCooldownDesc = 'Personnaliser l\'animation et les paramètres de balayage'
L.ThemeTextDesc = 'Personnaliser l\'apparence et le format du texte du compte à rebours'

-- Cooldown display options
L.DrawText = 'Afficher le texte'
L.DrawTextDesc = 'Contrôler la visibilité du texte du compte à rebours'
L.DrawSwipe = 'Afficher le balayage'
L.DrawSwipeDesc = 'Contrôler l\'animation de balayage radial'
L.DrawEdge = 'Afficher le bord'
L.DrawEdgeDesc = 'Contrôler le bord lumineux du balayage'
L.DrawBling = 'Afficher l\'éclat'
L.DrawBlingDesc = 'Contrôler l\'effet d\'éclat à la fin de la recharge'
L.Reverse = 'Inverser'
L.ReverseDesc = 'Inverser la direction du balayage'
L.SwipeColor = 'Couleur du balayage'
L.SwipeColorDesc = 'Remplacer la couleur de l\'animation de balayage de recharge'
L.UseAuraDisplayTime = 'Arrondi de durée d\'aura'
L.UseAuraDisplayTimeDesc = 'Contrôle l\'arrondi des durées d\'aura. Toujours arrondit vers le bas, Jamais arrondit vers le haut'

-- Countdown text options
L.MinDuration = 'Durée minimale'
L.MinDurationDesc = 'Durée minimale, en secondes, d\'un temps de recharge pour afficher le texte du compte à rebours'
L.TenthsThreshold = 'Seuil de dixièmes'
L.TenthsThresholdDesc = 'Afficher les dixièmes de seconde quand le temps de recharge restant est inférieur à cette valeur'
L.AbbrevThreshold = 'Seuil MM:SS'
L.AbbrevThresholdDesc = 'Durée, en secondes, avant que le texte passe au format MM:SS (ex. "1:30" au lieu de "90")'

-- Font options
L.FontFace = 'Police'
L.FontOutline = 'Contour de police'
L.FontSize = 'Taille de police'
L.Outline_OUTLINE = 'Fin'
L.Outline_OUTLINEMONOCHROME = 'Monochrome'
L.Outline_THICKOUTLINE = 'Épais'

-- Position / shadow
L.Anchor = 'Position'
L.Anchor_BOTTOM = 'Bas'
L.Anchor_BOTTOMLEFT = 'Bas gauche'
L.Anchor_BOTTOMRIGHT = 'Bas droite'
L.Anchor_CENTER = 'Centre'
L.Anchor_LEFT = 'Gauche'
L.Anchor_RIGHT = 'Droite'
L.Anchor_TOP = 'Haut'
L.Anchor_TOPLEFT = 'Haut gauche'
L.Anchor_TOPRIGHT = 'Haut droite'
L.HorizontalOffset = 'Décalage horizontal'
L.VerticalOffset = 'Décalage vertical'

-- Tri-state values
L.DrawState_default = 'Par défaut'
L.DrawState_always = 'Toujours'
L.DrawState_never = 'Jamais'

-- Color threshold UI
L.AddColorThreshold = 'Ajouter un seuil de couleur'
L.Duration = 'Durée'
L.TextColor = 'Couleur du texte'
L.ColorRangeDays = '%d jour(s)'
L.ColorRangeHours = '%d heure(s)'
L.ColorRangeMinutes = '%d minute(s)'
L.ColorRangeSeconds = '%d seconde(s)'
L.ColorRangeAbove = 'Au-dessus de %s'
L.ColorRangeOrLess = '%s ou moins'
L.ColorRangeTo = '%s à %s'
L.ColorRangeAll = 'Toutes les durées'

-- Rules
L.Rules = 'Règles'

-- Builtin Rule Names
L.Rule_action = 'Boutons d\'action'
L.Rule_action_charge = 'Boutons d\'action - Recharge'
L.Rule_action_loc = 'Boutons d\'action - Perte de contrôle'
L.Rule_blizzard_zone = 'Capacité de zone'
L.Rule_blizzard_nameplates = 'Barres de nom'
L.Rule_everything = 'Tout le reste'

-- Profiles
L.Profile = 'Profil'
L.NewProfile = 'Nouveau profil'
L.DuplicateProfile = 'Copier'
L.ResetProfile = 'Réinitialiser'
L.DeleteProfile = 'Supprimer'
L.EnterNewProfileName = 'Entrez un nom pour le nouveau profil :'
