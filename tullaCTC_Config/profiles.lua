local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local AceGUI = LibStub('AceGUI-3.0')
local tullaCTC = _G.tullaCTC

local function getProfileList(excludeCurrent)
    local profiles = {}
    local current = tullaCTC.db:GetCurrentProfile()

    for _, name in pairs(tullaCTC.db:GetProfiles()) do
        if not (excludeCurrent and name == current) then
            profiles[name] = name
        end
    end

    return profiles
end

function Addon:BuildProfilesPanel(container)
    container:SetLayout("Flow")

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)

    -- title
    local title = AceGUI:Create("Label")
    title:SetText("|cFFFFD100" .. L.Profiles .. "|r  -  " .. L.ProfilesDesc)
    title:SetFontObject(GameFontNormalLarge)
    title:SetFullWidth(true)
    scroll:AddChild(title)

    -- current profile display
    local currentGroup = AceGUI:Create("InlineGroup")
    currentGroup:SetTitle(L.CurrentProfile)
    currentGroup:SetFullWidth(true)
    currentGroup:SetLayout("Flow")

    local currentLabel = AceGUI:Create("Label")
    currentLabel:SetText(tullaCTC.db:GetCurrentProfile())
    currentLabel:SetFontObject(GameFontHighlightLarge)
    currentLabel:SetFullWidth(true)
    scroll:AddChild(currentGroup)
    currentGroup:AddChild(currentLabel)

    -- switch profile
    local switchGroup = AceGUI:Create("InlineGroup")
    switchGroup:SetTitle(L.SwitchProfile)
    switchGroup:SetFullWidth(true)
    switchGroup:SetLayout("Flow")

    local switchDropdown = AceGUI:Create("Dropdown")
    switchDropdown:SetLabel(L.SelectProfile)
    switchDropdown:SetList(getProfileList())
    switchDropdown:SetValue(tullaCTC.db:GetCurrentProfile())
    switchDropdown:SetRelativeWidth(0.6)
    switchDropdown:SetCallback("OnValueChanged", function(_, _, val)
        tullaCTC.db:SetProfile(val)
    end)
    switchGroup:AddChild(switchDropdown)

    scroll:AddChild(switchGroup)

    -- new profile
    local newGroup = AceGUI:Create("InlineGroup")
    newGroup:SetTitle(L.NewProfile)
    newGroup:SetFullWidth(true)
    newGroup:SetLayout("Flow")

    local newEditBox = AceGUI:Create("EditBox")
    newEditBox:SetLabel(L.ProfileName)
    newEditBox:SetRelativeWidth(0.6)
    newEditBox:SetCallback("OnEnterPressed", function(widget, _, val)
        val = strtrim(val)
        if val ~= "" then
            tullaCTC.db:SetProfile(val)
            widget:SetText("")
        end
    end)
    newGroup:AddChild(newEditBox)

    scroll:AddChild(newGroup)

    -- copy from
    local copyGroup = AceGUI:Create("InlineGroup")
    copyGroup:SetTitle(L.CopyFrom)
    copyGroup:SetFullWidth(true)
    copyGroup:SetLayout("Flow")

    local copyDropdown = AceGUI:Create("Dropdown")
    copyDropdown:SetLabel(L.SelectProfile)
    copyDropdown:SetList(getProfileList(true))
    copyDropdown:SetRelativeWidth(0.6)

    local copyButton = AceGUI:Create("Button")
    copyButton:SetText(L.CopyProfile)
    copyButton:SetRelativeWidth(0.35)
    copyButton:SetCallback("OnClick", function()
        local val = copyDropdown:GetValue()
        if val then
            tullaCTC.db:CopyProfile(val)
        end
    end)

    copyGroup:AddChild(copyDropdown)
    copyGroup:AddChild(copyButton)
    scroll:AddChild(copyGroup)

    -- danger zone: reset and delete
    local dangerGroup = AceGUI:Create("InlineGroup")
    dangerGroup:SetTitle(L.ProfileActions)
    dangerGroup:SetFullWidth(true)
    dangerGroup:SetLayout("Flow")

    local resetButton = AceGUI:Create("Button")
    resetButton:SetText(L.ResetProfile)
    resetButton:SetRelativeWidth(0.35)
    resetButton:SetCallback("OnClick", function()
        tullaCTC.db:ResetProfile()
    end)
    dangerGroup:AddChild(resetButton)

    local deleteDropdown = AceGUI:Create("Dropdown")
    deleteDropdown:SetLabel(L.DeleteProfile)
    deleteDropdown:SetList(getProfileList(true))
    deleteDropdown:SetRelativeWidth(0.6)

    local deleteButton = AceGUI:Create("Button")
    deleteButton:SetText(DELETE)
    deleteButton:SetRelativeWidth(0.35)
    deleteButton:SetCallback("OnClick", function()
        local val = deleteDropdown:GetValue()
        if val then
            tullaCTC.db:DeleteProfile(val)
        end
    end)

    dangerGroup:AddChild(deleteDropdown)
    dangerGroup:AddChild(deleteButton)
    scroll:AddChild(dangerGroup)

    container:AddChild(scroll)
end
