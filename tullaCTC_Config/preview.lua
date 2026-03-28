local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("tullaCTC")
local DEFAULT_DURATION = 30

local function getRandomIcon()
    if type(GetSpellBookItemTexture) == "function" then
        local _, _, offset, numSlots = GetSpellTabInfo(GetNumSpellTabs())
        return GetSpellBookItemTexture(math.random(offset + numSlots - 1), 'player')
    end

    local info = C_SpellBook.GetSpellBookSkillLineInfo(C_SpellBook.GetNumSpellBookSkillLines())
    return C_SpellBook.GetSpellBookItemTexture(
        math.random(info.itemIndexOffset + info.numSpellBookItems - 1),
        Enum.SpellBookSpellBank.Player
    )
end

local PreviewDialog

local function createPreviewDialog()
    local dlg = CreateFrame("Frame", AddonName .. "PreviewDialog", UIParent, "UIPanelDialogTemplate")
    dlg:Hide()
    dlg:SetPoint("CENTER")
    dlg:EnableMouse(true)
    dlg:SetClampedToScreen(true)
    dlg:SetFrameStrata("TOOLTIP")
    dlg:SetMovable(true)
    dlg:SetSize(172, 172)
    dlg:SetToplevel(true)

    local tr = CreateFrame("Frame", nil, dlg, "TitleDragAreaTemplate")
    tr:SetAllPoints(dlg:GetName() .. "TitleBG")

    local title = dlg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("CENTER", tr)
    title:SetText(L.Preview)

    local container = CreateFrame("Frame", nil, dlg)
    container:SetPoint("TOPLEFT", 10, -27)
    container:SetPoint("BOTTOMRIGHT", -7, 9)

    local bg = container:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 0.3)
    bg:SetAllPoints()

    local icon = container:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ActionButton1:GetWidth() * 2, ActionButton1:GetHeight() * 2)
    icon:SetPoint("TOP", 0, -4)
    dlg.Icon = icon

    local cooldown = CreateFrame("Cooldown", nil, container, "CooldownFrameTemplate")
    cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL
    cooldown:SetAllPoints(icon)
    cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    cooldown:SetSwipeColor(0, 0, 0)
    cooldown:SetDrawEdge(false)
    cooldown:SetHideCountdownNumbers(false)
    dlg.Cooldown = cooldown

    local durationLabel = container:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    durationLabel:SetText(L.Duration)
    durationLabel:SetPoint("TOP", icon, "BOTTOM", 0, -2)

    local durationInput = CreateFrame("EditBox", "$parentDurationInput", container, "NumericInputSpinnerTemplate")
    durationInput:SetAutoFocus(false)
    durationInput:SetPoint("TOP", durationLabel, "BOTTOM", 4, -2)
    durationInput:SetWidth(container:GetWidth() - 54)
    durationInput:SetMinMaxValues(0, 9999999)
    durationInput:SetMaxLetters(7)
    durationInput:SetValue(DEFAULT_DURATION)
    dlg.DurationInput = durationInput

    local function startCooldown(duration)
        dlg.Cooldown:SetCooldownDuration(tonumber(duration) or 0)
    end

    durationInput:SetOnValueChangedCallback(function(_, value)
        startCooldown(value or 0)
    end)

    cooldown:SetScript("OnCooldownDone", function()
        if dlg:IsVisible() then
            dlg.Icon:SetTexture(getRandomIcon())
            startCooldown(dlg.DurationInput:GetValue())
        end
    end)

    dlg:SetScript("OnShow", function(self)
        self.Icon:SetTexture(getRandomIcon())
        startCooldown(self.DurationInput:GetValue())
    end)

    dlg:SetScript("OnHide", function(self)
        self.Cooldown:Clear()
    end)

    function dlg:SetTheme(themeName)
        self.themeName = themeName
        self:Show()
    end

    return dlg
end

function Addon:GetPreviewDialog()
    if not PreviewDialog then
        PreviewDialog = createPreviewDialog()
    end
    return PreviewDialog
end
