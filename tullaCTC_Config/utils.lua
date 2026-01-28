-- Utility functions for tullaCTC configuration

local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)

--------------------------------------------------------------------------------
-- Color Utilities
--------------------------------------------------------------------------------

function Addon:HexToRGBA(hex)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    local a = tonumber(hex:sub(7, 8), 16) / 255

    return r, g, b, a
end

function Addon:RGBAToHex(r, g, b, a)
    return ("%02X%02X%02X%02X"):format(
        Round(r * 255),
        Round(g * 255),
        Round(b * 255),
        Round(a * 255)
    )
end

--------------------------------------------------------------------------------
-- Duration Formatting
--------------------------------------------------------------------------------

function Addon:FormatDuration(seconds)
    if seconds == math.huge then
        return L.ColorRangeForever
    elseif seconds >= 86400 then
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

    if currentThreshold == math.huge then
        if prevThreshold then
            return L.ColorRangeAbove:format(self:FormatDuration(prevThreshold))
        else
            return L.ColorRangeAll
        end
    elseif not prevThreshold or prevThreshold == 0 then
        return L.ColorRangeUpTo:format(endDuration)
    else
        return L.ColorRangeBetween:format(self:FormatDuration(prevThreshold), endDuration)
    end
end

--------------------------------------------------------------------------------
-- Threshold Parsing
--------------------------------------------------------------------------------

function Addon:ParseThreshold(val)
    val = strtrim(val)

    if val:lower() == "inf" or val:lower() == "infinite" or val:lower() == "forever" then
        return math.huge
    end

    local num = tonumber(val)
    if num and num > 0 then
        return num
    end

    return nil
end

function Addon:FormatThreshold(threshold)
    if threshold == math.huge then
        return "inf"
    end
    return tostring(threshold)
end

function Addon:ValidateThreshold(val)
    return self:ParseThreshold(val) ~= nil
end

--------------------------------------------------------------------------------
-- AceConfig Option Builders
--------------------------------------------------------------------------------

-- Creates a range slider option for a theme property
function Addon:CreateRangeOption(theme, property, opts)
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
            local val = theme[property] or default
            return invert and -val or val
        end,
        set = function(_, val)
            self:SetThemeProperty(theme, property, invert and -val or val)
        end
    }
end

-- Creates a select dropdown option for a theme property
function Addon:CreateSelectOption(theme, property, opts)
    return {
        type = 'select',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        dialogControl = opts.dialogControl,
        values = opts.values,
        get = function()
            return theme[property] or opts.default
        end,
        set = function(_, val)
            self:SetThemeProperty(theme, property, val)
        end
    }
end

-- Creates a toggle checkbox option for a theme property
function Addon:CreateToggleOption(theme, property, opts)
    return {
        type = 'toggle',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        get = function()
            return theme[property]
        end,
        set = function(_, val)
            self:SetThemeProperty(theme, property, val)
        end
    }
end

-- Creates a color picker option for a hex color theme property
function Addon:CreateColorOption(theme, property, opts)
    local default = opts.default or "FFFFFFFF"

    return {
        type = 'color',
        name = opts.name,
        desc = opts.desc,
        order = opts.order,
        width = opts.width,
        hasAlpha = opts.hasAlpha ~= false,
        get = function()
            return self:HexToRGBA(theme[property] or default)
        end,
        set = function(_, r, g, b, a)
            self:SetThemeProperty(theme, property, self:RGBAToHex(r, g, b, a))
        end
    }
end

-- Creates a tri-state select option (default/always/never)
function Addon:CreateDrawStateOption(theme, property, opts)
    return {
        type = 'select',
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
            return theme[property] or "default"
        end,
        set = function(_, val)
            self:SetThemeProperty(theme, property, val)
        end
    }
end
