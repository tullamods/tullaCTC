-- tullaCTC configuration localization - Latin American Spanish
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'esMX')
if not L then return end

-- Section headers
L.CooldownAppearance = 'Apariencia de reutilización'
L.CountdownText = 'Texto de cuenta regresiva'
L.CountdownTextColors = 'Colores del texto de cuenta regresiva'
L.TextFont = 'Fuente del texto'
L.TextPosition = 'Posición del texto'
L.TextShadow = 'Sombra del texto'

-- Theme management
L.Themes = 'Temas'
L.SelectTheme = 'Tema'
L.NewTheme = 'Nuevo tema'
L.CopyTheme = 'Copiar'
L.RenameTheme = 'Renombrar'
L.ResetTheme = 'Restablecer'
L.EnterThemeName = 'Introduce un nombre para el nuevo tema:'
L.DeleteThemeConfirm = '¿Estás seguro de que quieres eliminar "%s"?'

-- Theme settings
L.ThemeEnabled = 'Activar tema'
L.ThemeEnabledDesc = 'Aplicar este tema a las reutilizaciones coincidentes'
L.ThemeCooldownDesc = 'Personalizar la animación de reutilización y los ajustes de barrido'
L.ThemeTextDesc = 'Personalizar la apariencia y el formato del texto de cuenta regresiva'

-- Cooldown display options
L.DrawText = 'Mostrar texto'
L.DrawTextDesc = 'Controlar la visibilidad del texto de cuenta regresiva'
L.DrawSwipe = 'Mostrar barrido'
L.DrawSwipeDesc = 'Controlar la animación de barrido radial'
L.DrawEdge = 'Mostrar borde'
L.DrawEdgeDesc = 'Controlar el borde brillante del barrido'
L.DrawBling = 'Mostrar destello'
L.DrawBlingDesc = 'Controlar el efecto de destello cuando termina la reutilización'
L.Reverse = 'Invertir'
L.ReverseDesc = 'Invertir la dirección del barrido'
L.SwipeColor = 'Color de barrido'
L.SwipeColorDesc = 'Anular el color de la animación de barrido de reutilización'

-- Countdown text options
L.RoundingMode = 'Modo de redondeo'
L.RoundingModeDesc = 'Controla la forma en que se redondean los valores de duración'
L.MinDuration = 'Duración mínima'
L.MinDurationDesc = 'Cuánto tiempo, en segundos, debe durar una reutilización para mostrar el texto de cuenta regresiva'
L.TenthsThreshold = 'Umbral de décimas'
L.TenthsThresholdDesc = 'Mostrar décimas de segundo cuando la reutilización restante sea menor que este valor'
L.AbbrevThreshold = 'Umbral MM:SS'
L.AbbrevThresholdDesc = 'Cuánto tiempo, en segundos, antes de que el texto cambie a formato MM:SS (ej. "1:30" en lugar de "90")'
L.ShowZero = 'Mostrar Cero'
L.ShowZeroDesc = 'Mostrar "0" para tiempos de reutilización redondeados a cero en lugar de texto vacío'

-- Font options
L.FontFace = 'Fuente'
L.FontOutline = 'Contorno del texto'
L.FontSize = 'Tamaño del texto'
L.Outline_OUTLINE = 'Fino'
L.Outline_OUTLINEMONOCHROME = 'Monocromo'
L.Outline_THICKOUTLINE = 'Grueso'

-- Position / shadow
L.Anchor = 'Posición'
L.Anchor_BOTTOM = 'Abajo'
L.Anchor_BOTTOMLEFT = 'Abajo a la izquierda'
L.Anchor_BOTTOMRIGHT = 'Abajo a la derecha'
L.Anchor_CENTER = 'Centro'
L.Anchor_LEFT = 'Izquierda'
L.Anchor_RIGHT = 'Derecha'
L.Anchor_TOP = 'Arriba'
L.Anchor_TOPLEFT = 'Arriba a la izquierda'
L.Anchor_TOPRIGHT = 'Arriba a la derecha'
L.HorizontalOffset = 'Desplazamiento horizontal'
L.VerticalOffset = 'Desplazamiento vertical'

-- Tri-state values
L.DrawState_default = 'Predeterminado'
L.DrawState_always = 'Siempre'
L.DrawState_never = 'Nunca'

-- Rounding mode values
L.RoundingMode_Up = 'Hacia arriba'
L.RoundingMode_Down = 'Hacia abajo'
L.RoundingMode_Nearest = 'Al más cercano'

-- Color threshold UI
L.AddColorThreshold = 'Añadir umbral de color'
L.Duration = 'Duración'
L.TextColor = 'Color de texto'
L.ColorRangeDays = '%d día(s)'
L.ColorRangeHours = '%d hora(s)'
L.ColorRangeMinutes = '%d minuto(s)'
L.ColorRangeSeconds = '%d segundo(s)'
L.ColorRangeAbove = 'Superior a %s'
L.ColorRangeOrLess = '%s o menos'
L.ColorRangeTo = '%s a %s'
L.ColorRangeAll = 'Todas las duraciones'

-- Rules
L.Rules = 'Reglas'

-- Builtin Rule Names
L.Rule_action = 'Botones de acción'
L.Rule_action_charge = 'Botones de acción - Recarga'
L.Rule_action_loc = 'Botones de acción - Pérdida de control'
L.Rule_blizzard_zone = 'Habilidad de zona'
L.Rule_blizzard_nameplates = 'Placas de nombre'
L.Rule_everything = 'Todo lo demás'

-- Profiles
L.Profile = 'Perfil'
L.NewProfile = 'Nuevo perfil'
L.DuplicateProfile = 'Copiar'
L.ResetProfile = 'Restablecer'
L.DeleteProfile = 'Eliminar'
L.EnterNewProfileName = 'Introduce un nombre para el nuevo perfil:'
