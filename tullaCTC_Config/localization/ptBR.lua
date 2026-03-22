-- tullaCTC configuration localization - Brazilian Portuguese
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'ptBR')
if not L then return end

-- Section headers
L.CooldownAppearance = 'Aparência de recarga'
L.CountdownText = 'Texto de contagem regressiva'
L.CountdownTextColors = 'Cores do texto de contagem regressiva'
L.TextFont = 'Fonte do texto'
L.TextPosition = 'Posição do texto'
L.TextShadow = 'Sombra do texto'

-- Theme management
L.Themes = 'Temas'
L.SelectTheme = 'Tema'
L.NewTheme = 'Novo tema'
L.CopyTheme = 'Copiar'
L.RenameTheme = 'Renomear'
L.ResetTheme = 'Redefinir'
L.EnterThemeName = 'Digite um nome para o novo tema:'
L.DeleteThemeConfirm = 'Tem certeza que deseja excluir "%s"?'

-- Theme settings
L.ThemeEnabled = 'Ativar tema'
L.ThemeEnabledDesc = 'Aplicar este tema às recargas correspondentes'
L.ThemeCooldownDesc = 'Personalizar animação de recarga e configurações de varredura'
L.ThemeTextDesc = 'Personalizar aparência e formatação do texto de contagem regressiva'

-- Cooldown display options
L.DrawText = 'Mostrar texto'
L.DrawTextDesc = 'Controlar a visibilidade do texto de contagem regressiva'
L.DrawSwipe = 'Mostrar varredura'
L.DrawSwipeDesc = 'Controlar a animação de varredura radial'
L.DrawEdge = 'Mostrar borda'
L.DrawEdgeDesc = 'Controlar a borda brilhante da varredura'
L.DrawBling = 'Mostrar brilho'
L.DrawBlingDesc = 'Controlar o efeito de brilho quando a recarga termina'
L.Reverse = 'Inverter'
L.ReverseDesc = 'Inverter a direção da varredura'
L.SwipeColor = 'Cor da varredura'
L.SwipeColorDesc = 'Substituir a cor da animação de varredura da recarga'
L.UseAuraDisplayTime = 'Arredondamento de duração de aura'
L.UseAuraDisplayTimeDesc = 'Controla o arredondamento das durações de aura. Sempre arredonda para baixo, Nunca arredonda para cima'

-- Countdown text options
L.MinDuration = 'Duração mínima'
L.MinDurationDesc = 'Quanto tempo, em segundos, uma recarga deve ter para exibir o texto de contagem regressiva'
L.TenthsThreshold = 'Limite de décimos'
L.TenthsThresholdDesc = 'Mostrar décimos de segundo quando a recarga restante for menor que este valor'
L.AbbrevThreshold = 'Limite MM:SS'
L.AbbrevThresholdDesc = 'Quanto tempo, em segundos, antes do texto mudar para formato MM:SS (ex. "1:30" em vez de "90")'

-- Font options
L.FontFace = 'Fonte'
L.FontOutline = 'Contorno da fonte'
L.FontSize = 'Tamanho da fonte'
L.Outline_OUTLINE = 'Fino'
L.Outline_OUTLINEMONOCHROME = 'Monocromático'
L.Outline_THICKOUTLINE = 'Grosso'

-- Position / shadow
L.Anchor = 'Posição'
L.Anchor_BOTTOM = 'Inferior'
L.Anchor_BOTTOMLEFT = 'Inferior esquerdo'
L.Anchor_BOTTOMRIGHT = 'Inferior direito'
L.Anchor_CENTER = 'Centro'
L.Anchor_LEFT = 'Esquerda'
L.Anchor_RIGHT = 'Direita'
L.Anchor_TOP = 'Superior'
L.Anchor_TOPLEFT = 'Superior esquerdo'
L.Anchor_TOPRIGHT = 'Superior direito'
L.HorizontalOffset = 'Deslocamento horizontal'
L.VerticalOffset = 'Deslocamento vertical'

-- Tri-state values
L.DrawState_default = 'Padrão'
L.DrawState_always = 'Sempre'
L.DrawState_never = 'Nunca'

-- Color threshold UI
L.AddColorThreshold = 'Adicionar limite de cor'
L.Duration = 'Duração'
L.TextColor = 'Cor do texto'
L.ColorRangeDays = '%d dia(s)'
L.ColorRangeHours = '%d hora(s)'
L.ColorRangeMinutes = '%d minuto(s)'
L.ColorRangeSeconds = '%d segundo(s)'
L.ColorRangeAbove = 'Acima de %s'
L.ColorRangeOrLess = '%s ou menos'
L.ColorRangeTo = '%s a %s'
L.ColorRangeAll = 'Todas as durações'

-- Rules
L.Rules = 'Regras'

-- Builtin Rule Names
L.Rule_action = 'Botões de ação'
L.Rule_action_charge = 'Botões de ação - Recarga'
L.Rule_action_loc = 'Botões de ação - Perda de controle'
L.Rule_blizzard_zone = 'Habilidade de zona'
L.Rule_blizzard_nameplates = 'Placas de identificação'
L.Rule_everything = 'Todo o resto'

-- Profiles
L.Profile = 'Perfil'
L.NewProfile = 'Novo perfil'
L.DuplicateProfile = 'Copiar'
L.ResetProfile = 'Redefinir'
L.DeleteProfile = 'Excluir'
L.EnterNewProfileName = 'Digite um nome para o novo perfil:'
