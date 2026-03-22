-- tullaCTC configuration localization - Korean
local L = LibStub('AceLocale-3.0'):NewLocale('tullaCTC', 'koKR')
if not L then return end

-- Section headers
L.CooldownAppearance = '재사용 대기시간 외관'
L.CountdownText = '카운트다운 텍스트'
L.CountdownTextColors = '카운트다운 텍스트 색상'
L.TextFont = '텍스트 글꼴'
L.TextPosition = '텍스트 위치'
L.TextShadow = '텍스트 그림자'

-- Theme management
L.Themes = '테마'
L.SelectTheme = '테마'
L.NewTheme = '새 테마'
L.CopyTheme = '복사'
L.RenameTheme = '이름 변경'
L.ResetTheme = '초기화'
L.EnterThemeName = '새 테마의 이름을 입력하세요:'
L.DeleteThemeConfirm = '"%s"을(를) 정말 삭제하시겠습니까?'

-- Theme settings
L.ThemeEnabled = '테마 활성화'
L.ThemeEnabledDesc = '일치하는 재사용 대기시간에 이 테마를 적용합니다'
L.ThemeCooldownDesc = '재사용 대기시간 애니메이션 및 쓸기 설정 사용자 지정'
L.ThemeTextDesc = '카운트다운 텍스트 외관 및 서식 사용자 지정'

-- Cooldown display options
L.DrawText = '텍스트 표시'
L.DrawTextDesc = '카운트다운 텍스트 표시 여부 제어'
L.DrawSwipe = '쓸기 표시'
L.DrawSwipeDesc = '방사형 쓸기 애니메이션 제어'
L.DrawEdge = '가장자리 표시'
L.DrawEdgeDesc = '쓸기의 밝은 가장자리 제어'
L.DrawBling = '반짝임 표시'
L.DrawBlingDesc = '재사용 대기시간 완료 시 반짝임 효과 제어'
L.Reverse = '역방향'
L.ReverseDesc = '쓸기 방향 반전'
L.SwipeColor = '쓸기 색상'
L.SwipeColorDesc = '재사용 대기시간 쓸기 애니메이션 색상 덮어쓰기'
L.UseAuraDisplayTime = '오라 지속시간 반올림'
L.UseAuraDisplayTimeDesc = '오라 지속시간 반올림을 제어합니다. 항상은 내림, 안 함은 올림합니다'

-- Countdown text options
L.MinDuration = '최소 지속시간'
L.MinDurationDesc = '카운트다운 텍스트를 표시하기 위한 최소 재사용 대기시간(초)'
L.TenthsThreshold = '소수점 임계값'
L.TenthsThresholdDesc = '남은 재사용 대기시간이 이 값 미만일 때 소수점 이하를 표시합니다'
L.AbbrevThreshold = 'MM:SS 임계값'
L.AbbrevThresholdDesc = '텍스트가 MM:SS 형식으로 전환되기까지의 시간(초) (예: "90" 대신 "1:30")'

-- Font options
L.FontFace = '글꼴'
L.FontOutline = '글꼴 외곽선'
L.FontSize = '글꼴 크기'
L.Outline_OUTLINE = '얇게'
L.Outline_OUTLINEMONOCHROME = '모노크롬'
L.Outline_THICKOUTLINE = '두껍게'

-- Position / shadow
L.Anchor = '위치'
L.Anchor_BOTTOM = '하단'
L.Anchor_BOTTOMLEFT = '좌측 하단'
L.Anchor_BOTTOMRIGHT = '우측 하단'
L.Anchor_CENTER = '중앙'
L.Anchor_LEFT = '좌측'
L.Anchor_RIGHT = '우측'
L.Anchor_TOP = '상단'
L.Anchor_TOPLEFT = '좌측 상단'
L.Anchor_TOPRIGHT = '우측 상단'
L.HorizontalOffset = 'X 위치'
L.VerticalOffset = 'Y 위치'

-- Tri-state values
L.DrawState_default = '기본값'
L.DrawState_always = '항상'
L.DrawState_never = '안 함'

-- Color threshold UI
L.AddColorThreshold = '색상 임계값 추가'
L.Duration = '지속시간'
L.TextColor = '텍스트 색상'
L.ColorRangeDays = '%d일'
L.ColorRangeHours = '%d시간'
L.ColorRangeMinutes = '%d분'
L.ColorRangeSeconds = '%d초'
L.ColorRangeAbove = '%s 초과'
L.ColorRangeOrLess = '%s 이하'
L.ColorRangeTo = '%s ~ %s'
L.ColorRangeAll = '모든 지속시간'

-- Rules
L.Rules = '규칙'

-- Builtin Rule Names
L.Rule_action = '행동 단축 버튼'
L.Rule_action_charge = '행동 단축 버튼 - 충전'
L.Rule_action_loc = '행동 단축 버튼 - 제어 상실'
L.Rule_blizzard_zone = '지역 능력'
L.Rule_blizzard_nameplates = '이름표'
L.Rule_everything = '기타 모든 항목'

-- Profiles
L.Profile = '프로필'
L.NewProfile = '새 프로필'
L.DuplicateProfile = '복사'
L.ResetProfile = '초기화'
L.DeleteProfile = '삭제'
L.EnterNewProfileName = '새 프로필의 이름을 입력하세요:'
