local _, Addon = ...
local tullaCTC = _G.tullaCTC

-- create the options menu child frames
local options = {
    type = 'group',
    name = 'tullaCTC',
    childGroups = "tab",
    args = {
        themes = Addon.ThemeOptions,
        rules = Addon.RuleOptions,
        profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(tullaCTC.db, true)
    }
}

options.args.themes.order = 100
options.args.rules.order = 200
options.args.profiles.order = 300

LibStub('AceConfig-3.0'):RegisterOptionsTable("tullaCTC", options)

function Addon:OnProfileChanged()
    self:RefreshThemeOptions()
    self:RefreshRuleOptions()
end

tullaCTC.db.RegisterCallback(Addon, 'OnProfileChanged', 'OnProfileChanged')
tullaCTC.db.RegisterCallback(Addon, 'OnProfileCopied', 'OnProfileChanged')
tullaCTC.db.RegisterCallback(Addon, 'OnProfileReset', 'OnProfileChanged')
