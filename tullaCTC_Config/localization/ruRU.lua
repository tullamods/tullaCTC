-- tullaCTC configuration localization - Russian
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'ruRU')
if not L then return end

-- Section headers
L.CooldownAppearance = 'Внешний вид восстановления'
L.CountdownText = 'Текст обратного отсчёта'
L.CountdownTextColors = 'Цвета текста обратного отсчёта'
L.TextFont = 'Шрифт текста'
L.TextPosition = 'Расположение текста'
L.TextShadow = 'Тень текста'

-- Theme management
L.Themes = 'Темы'
L.SelectTheme = 'Тема'
L.NewTheme = 'Новая тема'
L.CopyTheme = 'Копировать'
L.RenameTheme = 'Переименовать'
L.ResetTheme = 'Сбросить'
L.EnterThemeName = 'Введите имя для новой темы:'
L.DeleteThemeConfirm = 'Вы уверены, что хотите удалить «%s»?'

-- Theme settings
L.ThemeEnabled = 'Включить тему'
L.ThemeEnabledDesc = 'Применить эту тему к соответствующим восстановлениям'
L.ThemeCooldownDesc = 'Настройка анимации восстановления и параметров затемнения'
L.ThemeTextDesc = 'Настройка внешнего вида и форматирования текста обратного отсчёта'

-- Cooldown display options
L.DrawText = 'Показать текст'
L.DrawTextDesc = 'Управление видимостью текста обратного отсчёта'
L.DrawSwipe = 'Показать затемнение'
L.DrawSwipeDesc = 'Управление радиальной анимацией затемнения'
L.DrawEdge = 'Показать край'
L.DrawEdgeDesc = 'Управление светящимся краем затемнения'
L.DrawBling = 'Показать вспышку'
L.DrawBlingDesc = 'Управление эффектом вспышки при завершении восстановления'
L.Reverse = 'Обратить'
L.ReverseDesc = 'Обратить направление затемнения'
L.SwipeColor = 'Цвет затемнения'
L.SwipeColorDesc = 'Заменить цвет анимации затемнения восстановления'
L.UseAuraDisplayTime = 'Округление длительности ауры'
L.UseAuraDisplayTimeDesc = 'Управление округлением длительности ауры. Всегда округляет вниз, Никогда округляет вверх'

-- Countdown text options
L.MinDuration = 'Минимальная длительность'
L.MinDurationDesc = 'Минимальная длительность восстановления в секундах для отображения текста обратного отсчёта'
L.TenthsThreshold = 'Порог десятых'
L.TenthsThresholdDesc = 'Показывать десятые доли секунды, когда оставшееся время восстановления ниже этого значения'
L.AbbrevThreshold = 'Порог ММ:СС'
L.AbbrevThresholdDesc = 'Через сколько секунд текст переключится на формат ММ:СС (например, «1:30» вместо «90»)'

-- Font options
L.FontFace = 'Шрифт'
L.FontOutline = 'Контур шрифта'
L.FontSize = 'Размер шрифта'
L.Outline_OUTLINE = 'Тонкий'
L.Outline_OUTLINEMONOCHROME = 'Одноцветный'
L.Outline_THICKOUTLINE = 'Толстый'

-- Position / shadow
L.Anchor = 'Привязка'
L.Anchor_BOTTOM = 'Внизу'
L.Anchor_BOTTOMLEFT = 'Внизу слева'
L.Anchor_BOTTOMRIGHT = 'Внизу справа'
L.Anchor_CENTER = 'По центру'
L.Anchor_LEFT = 'Слева'
L.Anchor_RIGHT = 'Справа'
L.Anchor_TOP = 'Вверху'
L.Anchor_TOPLEFT = 'Вверху слева'
L.Anchor_TOPRIGHT = 'Вверху справа'
L.HorizontalOffset = 'Горизонтальное смещение'
L.VerticalOffset = 'Вертикальное смещение'

-- Tri-state values
L.DrawState_default = 'По умолчанию'
L.DrawState_always = 'Всегда'
L.DrawState_never = 'Никогда'

-- Color threshold UI
L.AddColorThreshold = 'Добавить цветовой порог'
L.Duration = 'Длительность'
L.TextColor = 'Цвет текста'
L.ColorRangeDays = '%d дн.'
L.ColorRangeHours = '%d ч.'
L.ColorRangeMinutes = '%d мин.'
L.ColorRangeSeconds = '%d сек.'
L.ColorRangeAbove = 'Больше %s'
L.ColorRangeOrLess = '%s или менее'
L.ColorRangeTo = '%s до %s'
L.ColorRangeAll = 'Все длительности'

-- Rules
L.Rules = 'Правила'

-- Builtin Rule Names
L.Rule_action = 'Кнопки действий'
L.Rule_action_charge = 'Кнопки действий - Перезарядка'
L.Rule_action_loc = 'Кнопки действий - Потеря контроля'
L.Rule_blizzard_zone = 'Способность зоны'
L.Rule_blizzard_nameplates = 'Индикаторы здоровья'
L.Rule_everything = 'Всё остальное'

-- Profiles
L.Profile = 'Профиль'
L.NewProfile = 'Новый профиль'
L.DuplicateProfile = 'Копировать'
L.ResetProfile = 'Сбросить'
L.DeleteProfile = 'Удалить'
L.EnterNewProfileName = 'Введите имя для нового профиля:'
