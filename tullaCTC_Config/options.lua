local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local AceGUI = LibStub('AceGUI-3.0')
local tullaCTC = _G.tullaCTC

local frame
local tabs
local activeTab

local function selectTab(group)
    activeTab = group
    tabs:ReleaseChildren()

    if group == "themes" then
        Addon:BuildThemePanel(tabs)
    elseif group == "rules" then
        Addon:BuildRulesPanel(tabs)
    elseif group == "profiles" then
        Addon:BuildProfilesPanel(tabs)
    end
end

function tullaCTC:OpenOptions()
    if frame then
        frame:Show()
        return
    end

    frame = AceGUI:Create("Frame")
    frame.frame:SetToplevel(false)
    frame.frame:SetFrameStrata('HIGH')
    frame:SetTitle("tullaCTC")
    frame:SetLayout("Fill")
    frame:SetWidth(800)
    frame:SetHeight(600)
    frame:SetCallback("OnClose", function(widget)
        widget:Release()
        frame = nil
        tabs = nil
        activeTab = nil
    end)

    tabs = AceGUI:Create("TabGroup")
    tabs:SetTabs({
        { text = L.Themes, value = "themes" },
        { text = L.Rules, value = "rules" },
        { text = L.Profiles, value = "profiles" },
    })
    tabs:SetCallback("OnGroupSelected", function(_, _, group)
        selectTab(group)
    end)
    tabs:SelectTab("themes")

    frame:AddChild(tabs)
end

-- refresh the active tab when profile changes
function Addon:OnProfileChanged()
    if tabs and activeTab then
        selectTab(activeTab)
    end
end

tullaCTC.db.RegisterCallback(Addon, 'OnProfileChanged', 'OnProfileChanged')
tullaCTC.db.RegisterCallback(Addon, 'OnProfileCopied', 'OnProfileChanged')
tullaCTC.db.RegisterCallback(Addon, 'OnProfileReset', 'OnProfileChanged')
