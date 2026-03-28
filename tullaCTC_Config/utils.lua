local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local tullaCTC = _G.tullaCTC

Addon.DROPDOWN_HEIGHT = 25 -- height of dropdown/stepper controls
Addon.LABEL_WIDTH = 200    -- fixed width of the label column in widget rows
Addon.PADDING = 8          -- outer padding around panels and between label/control
Addon.SPACING = 6          -- vertical gap between rows in a layout

Addon.HexToRGBA = tullaCTC.HexToRGBA
Addon.RGBAToHex = tullaCTC.RGBAToHex

function Addon.GetThemeDisplayName(id)
    local theme = tullaCTC.db.profile.themes[id]
    if theme then
        return theme.displayName or rawget(L, 'Theme_' .. id) or id
    end
    return id
end

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

function Addon:FormatColorRange(prevThreshold, currentThreshold)
    if prevThreshold then
        return L.ColorRangeTo:format(self:FormatDuration(prevThreshold), self:FormatDuration(currentThreshold))
    else
        return L.ColorRangeOrLess:format(self:FormatDuration(currentThreshold))
    end
end

function Addon:FormatDefaultColorRange(lastThreshold)
    if lastThreshold then
        return L.ColorRangeAbove:format(self:FormatDuration(lastThreshold))
    else
        return L.ColorRangeAll
    end
end

function Addon:GetSortedThemeIDs()
    local themes = tullaCTC.db.profile.themes
    local order = {}

    for id in pairs(themes) do
        order[#order + 1] = id
    end

    table.sort(order, function(a, b)
        return self.GetThemeDisplayName(a) < self.GetThemeDisplayName(b)
    end)

    return order
end
