-- Utility functions for tullaCTC configuration

local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
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
-- AceConfig Option Builders
--------------------------------------------------------------------------------

-- Creates a range slider option for a theme property
function Addon:CreateRangeOption(themeID, property, opts)
    local default = opts.default or 0
    local invert = opts.invert

    return {
        type = 'range',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        min = opts.min,
        max = opts.max,
        softMin = opts.softMin,
        softMax = opts.softMax,
        step = opts.step or 1,
        get = function()
            local val = tullaCTC.db.profile.themes[themeID][property] or default
            return invert and -val or val
        end,
        set = function(_, val)
            self:SetThemeProperty(themeID, property, invert and -val or val)
        end
    }
end

-- Creates a select dropdown option for a theme property
function Addon:CreateSelectOption(themeID, property, opts)
    return {
        type = 'select',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        dialogControl = opts.dialogControl,
        values = opts.values,
        get = function()
            return tullaCTC.db.profile.themes[themeID][property] or opts.default
        end,
        set = function(_, val)
            self:SetThemeProperty(themeID, property, val)
        end
    }
end

-- Creates a toggle checkbox option for a theme property
function Addon:CreateToggleOption(themeID, property, opts)
    return {
        type = 'toggle',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        get = function()
            return tullaCTC.db.profile.themes[themeID][property]
        end,
        set = function(_, val)
            self:SetThemeProperty(themeID, property, val)
        end
    }
end

-- Creates a color picker option for a hex color theme property
function Addon:CreateColorOption(themeID, property, opts)
    local default = opts.default or "FFFFFFFF"

    return {
        type = 'color',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        hasAlpha = opts.hasAlpha ~= false,
        get = function()
            return self.HexToRGBA(tullaCTC.db.profile.themes[themeID][property] or default)
        end,
        set = function(_, r, g, b, a)
            self:SetThemeProperty(themeID, property, self.RGBAToHex(r, g, b, a))
        end
    }
end

-- Creates a tri-state select option (default/always/never)
function Addon:CreateDrawStateOption(themeID, property, opts)
    return {
        type = 'select',
        style = 'radio',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        values = {
            default = L.DrawState_default,
            always = L.DrawState_always,
            never = L.DrawState_never
        },
        sorting = { "default", "always", "never" },
        get = function()
            return tullaCTC.db.profile.themes[themeID][property] or "default"
        end,
        set = function(_, val)
            self:SetThemeProperty(themeID, property, val)
        end
    }
end
