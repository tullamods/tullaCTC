-- tullaCTC configuration localization - Simplified Chinese
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'zhCN')
if not L then return end

-- Section headers
L.CooldownAppearance = '冷却外观'
L.CountdownText = '倒计时文字'
L.CountdownTextColors = '倒计时文字颜色'
L.TextFont = '文字字体'
L.TextPosition = '文字位置'
L.TextShadow = '文字阴影'

-- Theme management
L.Themes = '主题'
L.SelectTheme = '主题'
L.NewTheme = '新主题'
L.CopyTheme = '复制'
L.RenameTheme = '重命名'
L.ResetTheme = '重置'
L.EnterThemeName = '输入新主题的名称：'
L.DeleteThemeConfirm = '确定要删除"%s"吗？'

-- Theme settings
L.ThemeEnabled = '启用主题'
L.ThemeEnabledDesc = '将此主题应用到匹配的冷却'
L.ThemeCooldownDesc = '自定义冷却动画和扫过设置'
L.ThemeTextDesc = '自定义倒计时文字外观和格式'

-- Cooldown display options
L.DrawText = '显示文字'
L.DrawTextDesc = '控制倒计时文字的可见性'
L.DrawSwipe = '显示扫过效果'
L.DrawSwipeDesc = '控制径向扫过动画'
L.DrawEdge = '显示边缘'
L.DrawEdgeDesc = '控制扫过效果的明亮边缘'
L.DrawBling = '显示闪光'
L.DrawBlingDesc = '控制冷却结束时的闪光效果'
L.Reverse = '反转'
L.ReverseDesc = '反转扫过方向'
L.SwipeColor = '扫过颜色'
L.SwipeColorDesc = '覆盖冷却扫过动画的颜色'
L.UseAuraDisplayTime = '光环持续时间取整'
L.UseAuraDisplayTimeDesc = '控制光环持续时间的取整方式。始终向下取整，从不向上取整'

-- Countdown text options
L.MinDuration = '最短持续时间'
L.MinDurationDesc = '冷却时间需要多长（秒）才会显示倒计时文字'
L.TenthsThreshold = '小数阈值'
L.TenthsThresholdDesc = '当剩余冷却时间低于此值时显示十分之一秒'
L.AbbrevThreshold = 'MM:SS阈值'
L.AbbrevThresholdDesc = '冷却文字切换到MM:SS格式之前的时间（秒）（例如用"1:30"代替"90"）'

-- Font options
L.FontFace = '字体'
L.FontOutline = '字体轮廓'
L.FontSize = '字体大小'
L.Outline_OUTLINE = '细边'
L.Outline_OUTLINEMONOCHROME = '无抗锯齿'
L.Outline_THICKOUTLINE = '粗边'

-- Position / shadow
L.Anchor = '锚点'
L.Anchor_BOTTOM = '下'
L.Anchor_BOTTOMLEFT = '左下'
L.Anchor_BOTTOMRIGHT = '右下'
L.Anchor_CENTER = '中'
L.Anchor_LEFT = '左'
L.Anchor_RIGHT = '右'
L.Anchor_TOP = '上'
L.Anchor_TOPLEFT = '左上'
L.Anchor_TOPRIGHT = '右上'
L.HorizontalOffset = '水平偏移'
L.VerticalOffset = '垂直偏移'

-- Tri-state values
L.DrawState_default = '默认'
L.DrawState_always = '始终'
L.DrawState_never = '从不'

-- Color threshold UI
L.AddColorThreshold = '添加颜色阈值'
L.Duration = '持续时间'
L.TextColor = '文字颜色'
L.ColorRangeDays = '%d天'
L.ColorRangeHours = '%d小时'
L.ColorRangeMinutes = '%d分钟'
L.ColorRangeSeconds = '%d秒'
L.ColorRangeAbove = '超过%s'
L.ColorRangeOrLess = '%s或更少'
L.ColorRangeTo = '%s到%s'
L.ColorRangeAll = '所有持续时间'

-- Rules
L.Rules = '规则'

-- Builtin Rule Names
L.Rule_action = '动作按钮'
L.Rule_action_charge = '动作按钮 - 充能'
L.Rule_action_loc = '动作按钮 - 失去控制'
L.Rule_blizzard_zone = '区域技能'
L.Rule_blizzard_nameplates = '姓名板'
L.Rule_everything = '其他所有'

-- Profiles
L.Profile = '配置文件'
L.NewProfile = '新配置文件'
L.DuplicateProfile = '复制'
L.ResetProfile = '重置'
L.DeleteProfile = '删除'
L.EnterNewProfileName = '输入新配置文件的名称：'
