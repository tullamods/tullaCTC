-- Utility functions for tullaCTC configuration

local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local AceGUI = LibStub('AceGUI-3.0')
local tullaCTC = _G.tullaCTC

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

Addon.HexToRGBA = tullaCTC.HexToRGBA
Addon.RGBAToHex = tullaCTC.RGBAToHex

--------------------------------------------------------------------------------
-- Duration Formatting
--------------------------------------------------------------------------------

function Addon:FormatDuration(seconds)
    if seconds >= 86400 then
        return L.ColorRangeDays:format(Round(seconds / 86400))
    elseif seconds >= 3600 then
        return L.ColorRangeHours:format(Round(seconds / 3600))
    elseif seconds >= 60 then
        return L.ColorRangeMinutes:format(Round(seconds / 60))
    else
        return L.ColorRangeSeconds:format(seconds)
    end
end

function Addon:FormatEffectiveRange(prevThreshold, currentThreshold)
    local endDuration = self:FormatDuration(currentThreshold)

    if not prevThreshold or prevThreshold == 0 then
        return L.ColorRangeOrLess:format(endDuration)
    else
        return L.ColorRangeTo:format(self:FormatDuration(prevThreshold), endDuration)
    end
end

function Addon:FormatDefaultColorRange(lastThreshold)
    if lastThreshold then
        return L.ColorRangeAbove:format(self:FormatDuration(lastThreshold))
    else
        return L.ColorRangeAll
    end
end

--------------------------------------------------------------------------------
-- Threshold Parsing
--------------------------------------------------------------------------------

function Addon:ParseThreshold(val)
    local num = tonumber(strtrim(val))

    if num and num > 0 then
        return num
    end

    return nil
end

function Addon:FormatThreshold(threshold)
    return tostring(threshold)
end

--------------------------------------------------------------------------------
-- AceGUI Widget Builders
--------------------------------------------------------------------------------

-- Creates a checkbox widget for a theme property
function Addon:AddCheckBox(parent, themeID, property, opts)
    local widget = AceGUI:Create("CheckBox")

    widget:SetLabel(opts.name)
    if opts.width then widget:SetRelativeWidth(opts.width) end
    if opts.fullWidth then widget:SetFullWidth(true) end
    widget:SetValue(tullaCTC.db.profile.themes[themeID][property])

    if opts.desc then
        widget:SetCallback("OnEnter", function()
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText(opts.name, 1, 0.82, 0)
            GameTooltip:AddLine(opts.desc, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        widget:SetCallback("OnLeave", GameTooltip_Hide)
    end

    widget:SetCallback("OnValueChanged", function(_, _, val)
        self:SetThemeProperty(themeID, property, val)
    end)

    parent:AddChild(widget)
    return widget
end

-- Creates a slider widget for a theme property
function Addon:AddSlider(parent, themeID, property, opts)
    local default = opts.default or 0
    local invert = opts.invert

    local widget = AceGUI:Create("Slider")

    widget:SetLabel(opts.name)
    if opts.fullWidth then widget:SetFullWidth(true) end
    if opts.width then widget:SetRelativeWidth(opts.width) end

    local sliderMin = opts.softMin or opts.min or 0
    local sliderMax = opts.softMax or opts.max or 100
    widget:SetSliderValues(sliderMin, sliderMax, opts.step or 1)

    local val = tullaCTC.db.profile.themes[themeID][property] or default
    widget:SetValue(invert and -val or val)

    widget:SetCallback("OnValueChanged", function(_, _, val)
        self:SetThemeProperty(themeID, property, invert and -val or val)
    end)

    parent:AddChild(widget)
    return widget
end

-- Creates a dropdown widget for a theme property
function Addon:AddDropdown(parent, themeID, property, opts)
    local widget = AceGUI:Create(opts.dialogControl or "Dropdown")

    widget:SetLabel(opts.name)
    if opts.width then widget:SetRelativeWidth(opts.width) end
    if opts.fullWidth then widget:SetFullWidth(true) end
    widget:SetList(opts.values)
    widget:SetValue(tullaCTC.db.profile.themes[themeID][property] or opts.default)

    widget:SetCallback("OnValueChanged", function(_, _, val)
        self:SetThemeProperty(themeID, property, val)
    end)

    parent:AddChild(widget)
    return widget
end

-- Creates a color picker widget for a hex color theme property
function Addon:AddColorPicker(parent, themeID, property, opts)
    local default = opts.default or "FFFFFFFF"

    local widget = AceGUI:Create("ColorPicker")

    widget:SetLabel(opts.name)
    if opts.width then widget:SetRelativeWidth(opts.width) end
    if opts.fullWidth then widget:SetFullWidth(true) end
    widget:SetHasAlpha(opts.hasAlpha ~= false)

    local r, g, b, a = self.HexToRGBA(tullaCTC.db.profile.themes[themeID][property] or default)
    widget:SetColor(r, g, b, a)

    widget:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
        self:SetThemeProperty(themeID, property, self.RGBAToHex(r, g, b, a))
    end)

    parent:AddChild(widget)
    return widget
end

-- Creates a tri-state dropdown (default/always/never) for a theme property
function Addon:AddDrawStateDropdown(parent, themeID, property, opts)
    local widget = AceGUI:Create("Dropdown")

    widget:SetLabel(opts.name)
    if opts.width then widget:SetRelativeWidth(opts.width) end
    if opts.fullWidth then widget:SetFullWidth(true) end

    widget:SetList({
        default = L.DrawState_default,
        always = L.DrawState_always,
        never = L.DrawState_never,
    }, { "default", "always", "never" })

    widget:SetValue(tullaCTC.db.profile.themes[themeID][property] or "default")

    widget:SetCallback("OnValueChanged", function(_, _, val)
        self:SetThemeProperty(themeID, property, val)
    end)

    parent:AddChild(widget)
    return widget
end
