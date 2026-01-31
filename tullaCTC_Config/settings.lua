-- Settings API for tullaCTC configuration
-- Handles data access and manipulation, separate from UI

local _, Addon = ...
local tullaCTC = _G.tullaCTC

--------------------------------------------------------------------------------
-- Theme Management
--------------------------------------------------------------------------------

function Addon:GetThemes()
    return tullaCTC.db.profile.themes
end

function Addon:HasTheme(themeID)
    return rawget(tullaCTC.db.profile.themes, themeID) ~= nil
end

function Addon:CreateTheme(name, baseThemeID)
    local key = "custom_" .. name
    if self:HasTheme(key) then
        return nil
    end

    if baseThemeID and self:HasTheme(baseThemeID) then
        local theme = CopyTable(tullaCTC.db.profile.themes[baseThemeID])

        theme.base = baseThemeID
        theme.displayName = name

        tullaCTC.db.profile.themes[key] = theme
    else
        tullaCTC.db.profile.themes[key].displayName = name
    end

    tullaCTC:Refresh()
    return key
end

function Addon:DeleteTheme(themeID)
    if themeID == "default" then
        return false
    end

    tullaCTC.db.profile.themes[themeID] = nil
    tullaCTC:Refresh()
    return true
end

function Addon:ResetTheme(themeID)
    if not self:HasTheme(themeID) then
        return false
    end

    -- grab values we want to persist after resetting
    local theme = tullaCTC.db.profile.themes[themeID]
    local baseThemeID = theme.base
    local displayName = theme.displayName

    tullaCTC.db.profile.themes[themeID] = nil
    return self:CreateTheme(displayName or themeID, baseThemeID)
end

function Addon:RenameTheme(themeID, newName)
    local theme = self:GetTheme(themeID)
    if not theme then
        return false
    end

    theme.displayName = newName
    return true
end

--------------------------------------------------------------------------------
-- Theme Config API
--------------------------------------------------------------------------------

function Addon:SetThemeProperty(themeID, property, value)
    local theme = tullaCTC.db.profile.themes[themeID]
    local oldValue = theme[property]

    if oldValue ~= value then
        theme[property] = value
        tullaCTC:Refresh()
        return true
    end

    return false
end

function Addon:GetSortedTextColors(theme)
    table.sort(theme.textColors, function(a, b)
        return a.threshold < b.threshold
    end)

    return theme.textColors
end

function Addon:AddTextColorEntry(theme, threshold, color)
    if not (threshold and threshold > 0) then
        return false
    end

    local entries = theme.textColors

    local index = #entries + 1
    for i, entry in ipairs(entries) do
        if entry.threshold == threshold then
            return false
        elseif entry.threshold > threshold then
            index = i
            break
        end
    end

    tinsert(entries, index, {
        threshold = threshold,
        color = color or "FFFFFFFF"
    })

    tullaCTC:Refresh()
    return true
end

function Addon:RemoveTextColorEntry(theme, index)
    local entries = theme.textColors

    if index > 0 and index <= #entries then
        tremove(entries, index)
        tullaCTC:Refresh()
        return true
    end

    return false
end

-- ensure textColors is a profile-specific copy before modifying
function Addon:SetTextColorValue(theme, index, color)
    local entry = theme.textColors[index]

    if entry.color ~= color then
        entry.color = color
        tullaCTC:Refresh()
        return true
    end

    return false
end

function Addon:SetTextColorThreshold(theme, index, threshold)
    if not (threshold and threshold > 0) then
        return false
    end

    local entries = theme.textColors
    for _, entry in pairs(entries) do
        if entry.threshold == threshold then
            return false
        end
    end

    entries[index].threshold = threshold
    tullaCTC:Refresh()
    return true
end
