local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("tullaCTC")
local DEFAULT_DURATION = 30

local function getRandomIcon()
    if type(GetSpellBookItemTexture) == "function" then
        local _, _, offset, numSlots = GetSpellTabInfo(GetNumSpellTabs())
        return GetSpellBookItemTexture(math.random(offset + numSlots - 1), 'player')
    end

    local i = C_SpellBook.GetSpellBookSkillLineInfo(C_SpellBook.GetNumSpellBookSkillLines())
    local offset = i.itemIndexOffset
    local numSlots = i.numSpellBookItems
    return C_SpellBook.GetSpellBookItemTexture(math.random(offset + numSlots - 1), Enum.SpellBookSpellBank.Player)
end

local PreviewDialog

local function createPreviewDialog()
    local dlg = CreateFrame("Frame", AddonName .. "PreviewDialog", UIParent, "UIPanelDialogTemplate")

    dlg:Hide()
    dlg:ClearAllPoints()
    dlg:SetPoint("CENTER")
    dlg:EnableMouse(true)
    dlg:SetClampedToScreen(true)
    dlg:SetFrameStrata("TOOLTIP")
    dlg:SetMovable(true)
    dlg:SetSize(172, 172)
    dlg:SetToplevel(true)
    dlg:SetScript(
        "OnShow",
        function(self)
            self.icon:SetTexture(getRandomIcon())
            self:StartCooldown(self.duration:GetValue())
        end
    )

    dlg:SetScript(
        "OnHide",
        function(self)
            if self:IsShown() then
                self:Hide()
            end
            self.cooldown:Clear()
        end
    )

    -- title region
    local tr = CreateFrame("Frame", nil, dlg, "TitleDragAreaTemplate")
    tr:SetAllPoints(dlg:GetName() .. "TitleBG")

    local text = dlg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("CENTER", tr)
    text:SetText(L.Preview)

    -- container
    local container = CreateFrame("Frame", nil, dlg)
    container:SetPoint("TOPLEFT", 10, -27)
    container:SetPoint("BOTTOMRIGHT", -7, 9)

    local bg = container:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 0.3)
    bg:SetAllPoints()

    -- action icon
    local icon = container:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ActionButton1:GetWidth() * 2, ActionButton1:GetHeight() * 2)
    icon:SetPoint("TOP", 0, -4)
    dlg.icon = icon

    -- cooldown
    local cooldown = CreateFrame("Cooldown", nil, container, "CooldownFrameTemplate")
    cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL
    cooldown:SetAllPoints(icon)
    cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    cooldown:SetSwipeColor(0, 0, 0)
    cooldown:SetDrawEdge(false)
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetScript(
        "OnCooldownDone",
        function()
            if dlg:IsVisible() then
                dlg.icon:SetTexture(getRandomIcon())
                dlg:StartCooldown(dlg.duration:GetValue())
            end
        end
    )
    dlg.cooldown = cooldown

    -- duration input
    local editBoxText = container:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    editBoxText:SetText(L.Duration)
    editBoxText:SetPoint("TOP", icon, "BOTTOM", 0, -2)

    local editBox = CreateFrame('EditBox', "$parentDurationInput", container, "NumericInputSpinnerTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetPoint("TOP", editBoxText, "BOTTOM", 4, -2)
    editBox:SetWidth(container:GetWidth() - 54)
    editBox:SetMinMaxValues(0, 9999999)
    editBox:SetMaxLetters(7)
    editBox:SetValue(DEFAULT_DURATION)
    editBox:SetOnValueChangedCallback(function(_, value)
        dlg:StartCooldown(value or 0)
    end)
    dlg.duration = editBox

    function dlg:SetTheme(themeName)
        self.themeName = themeName
        self:Show()
    end

    function dlg:StartCooldown(duration)
        self.cooldown:SetCooldownDuration(tonumber(duration) or 0)
    end

    return dlg
end

function Addon:GetPreviewDialog()
    if not PreviewDialog then
        PreviewDialog = createPreviewDialog()
    end
    return PreviewDialog
end
