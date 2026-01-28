-- Settings API for tullaCTC configuration
-- Handles data access and manipulation, separate from UI

local _, Addon = ...
local tullaCTC = _G.tullaCTC

--------------------------------------------------------------------------------
-- Theme API
--------------------------------------------------------------------------------

function Addon:GetThemes()
    return tullaCTC.db.profile.themes
end

function Addon:GetTheme(id)
    return tullaCTC.db.profile.themes[id]
end

function Addon:GetThemeChoices()
    local choices = {}

    for id, theme in pairs(self:GetThemes()) do
        choices[id] = theme.displayName or id
    end

    return choices
end

function Addon:ThemeExists(id)
    return rawget(tullaCTC.db.profile.themes, id) ~= nil
end

function Addon:CreateTheme(name, baseID)
    local key = "custom_" .. name

    if self:ThemeExists(key) then
        return nil
    end

    if baseID then
        local source = self:GetTheme(baseID)
        if not source then
            return nil
        end

        local copy = CopyTable(source)
        copy.displayName = name
        copy.base = baseID
        tullaCTC.db.profile.themes[key] = copy
    else
        tullaCTC.db.profile.themes[key].displayName = name
    end

    tullaCTC:Refresh()
    return key
end

function Addon:DeleteTheme(id)
    if id == "default" then
        return false
    end

    tullaCTC.db.profile.themes[id] = nil
    tullaCTC:Refresh()
    return true
end

function Addon:CopyTheme(id)
    local source = self:GetTheme(id)
    if not source then
        return nil
    end

    local baseName = source.displayName or id
    local copyName = baseName .. " Copy)"
    local counter = 2

    while self:ThemeExists("custom_" .. copyName) do
        copyName = baseName .. " (Copy " .. counter .. ")"
        counter = counter + 1
    end

    return self:CreateTheme(copyName, id)
end

function Addon:ResetTheme(id)
    local theme = self:GetTheme(id)
    if not theme then
        return false
    end

    local baseID = theme.base
    local displayName = theme.displayName
    tullaCTC.db.profile.themes[id] = nil

    if baseID then
        local source = self:GetTheme(baseID)
        if source then
            local copy = CopyTable(source)
            copy.displayName = displayName
            copy.baseTheme = baseID
            tullaCTC.db.profile.themes[id] = copy
        else
            tullaCTC.db.profile.themes[id].displayName = displayName
        end
    else
        tullaCTC.db.profile.themes[id].displayName = displayName
    end

    tullaCTC:Refresh()
    return true
end

function Addon:RenameTheme(id, newName)
    local theme = self:GetTheme(id)
    if not theme then
        return false
    end

    theme.displayName = newName
    return true
end

function Addon:SetThemeProperty(theme, property, value)
    theme[property] = value
    tullaCTC:Refresh()
end

--------------------------------------------------------------------------------
-- Text Colors API
--------------------------------------------------------------------------------

function Addon:GetTextColors(theme)
    local colors = theme.textColors or {}

    table.sort(colors, function(a, b)
        return a.threshold < b.threshold
    end)

    return colors
end

function Addon:GetTextColorEntry(theme, index)
    return self:GetTextColors(theme)[index]
end

function Addon:AddTextColor(theme, threshold, color)
    theme.textColors = theme.textColors or {}

    local index = #theme.textColors + 1
    for i, entry in ipairs(theme.textColors) do
        if entry.threshold == threshold then
            return false
        elseif entry.threshold > threshold then
            index = i
            break
        end
    end

    table.insert(theme.textColors, index, {
        threshold = threshold,
        color = color or "FFFFFFFF"
    })

    tullaCTC:Refresh()
    return true
end

function Addon:RemoveTextColor(theme, index)
    local colors = theme.textColors

    if colors and colors[index] then
        table.remove(colors, index)
        tullaCTC:Refresh()
        return true
    end

    return false
end

function Addon:SetTextColorValue(theme, index, r, g, b, a)
    local entry = theme.textColors[index]
    if entry then
        entry.color = self:RGBAToHex(r, g, b, a)
        tullaCTC:Refresh()
        return true
    end

    return false
end

function Addon:SetTextColorThreshold(theme, index, threshold)
    local colors = self:GetTextColors(theme)
    local entry = colors[index]

    if not entry then
        return false
    end

    -- Check for duplicate (excluding current entry)
    for j, e in ipairs(colors) do
        if j ~= index and e.threshold == threshold then
            return false
        end
    end

    entry.threshold = threshold
    tullaCTC:Refresh()
    return true
end
