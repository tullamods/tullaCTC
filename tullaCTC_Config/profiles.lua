local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

StaticPopupDialogs["TULLACTC_NEW_PROFILE"] = {
    text = L.EnterNewProfileName,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    OnAccept = function(self, sourceProfile)
        local name = self.EditBox:GetText():trim()
        if name ~= "" then
            tullaCTC.db:SetProfile(name)
            if sourceProfile then
                tullaCTC.db:CopyProfile(sourceProfile)
            end
        end
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    whileDead = true,
    hideOnEscape = true,
}

local function generateProfileMenu(_, rootDescription)
    local profiles = {}

    for _, name in pairs(tullaCTC.db:GetProfiles()) do
        profiles[#profiles + 1] = name
    end
    table.sort(profiles)

    local count = #profiles

    for _, name in ipairs(profiles) do
        local entry = rootDescription:CreateRadio(name,
            function() return tullaCTC.db:GetCurrentProfile() == name end,
            function() tullaCTC.db:SetProfile(name) end)

        entry:CreateButton(L.DuplicateProfile, function()
            StaticPopup_Show("TULLACTC_NEW_PROFILE", nil, nil, name)
        end)

        entry:CreateDivider()

        entry:CreateButton(L.ResetProfile, function()
            tullaCTC.db:SetProfile(name)
            tullaCTC.db:ResetProfile()
        end)

        local deleteEntry = entry:CreateButton(L.DeleteProfile, function()
            tullaCTC.db:DeleteProfile(name)
        end)
        if count <= 1 or name == tullaCTC.db:GetCurrentProfile() then
            deleteEntry:SetEnabled(false)
        end
    end

    rootDescription:CreateDivider()

    rootDescription:CreateButton(L.NewProfile, function()
        StaticPopup_Show("TULLACTC_NEW_PROFILE")
    end)
end

function Addon:BuildProfileDropdown(parent)
    local dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dd:SetupMenu(generateProfileMenu)

    tullaCTC.db.RegisterCallback(dd, "OnProfileChanged", function()
        dd:GenerateMenu()
    end)
    tullaCTC.db.RegisterCallback(dd, "OnProfileCopied", function()
        dd:GenerateMenu()
    end)

    return dd
end
