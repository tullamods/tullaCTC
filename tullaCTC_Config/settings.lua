local _, Addon = ...
local tullaCTC = _G.tullaCTC

-- Addon-level callbacks for data → UI communication
Mixin(Addon, CallbackRegistryMixin)
CallbackRegistryMixin.OnLoad(Addon)

Addon:GenerateCallbackEvents {
    "OnThemeListChanged",
    "OnThemeColorsChanged",
}

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
        -- AceDB ['**'] defaults auto-create this table on first index
        tullaCTC.db.profile.themes[key].displayName = name
    end

    tullaCTC:Refresh()
    self:TriggerEvent("OnThemeListChanged", key)
    return key
end

function Addon:DeleteTheme(themeID)
    if themeID == "default" then
        return false
    end

    tullaCTC.db.profile.themes[themeID] = nil

    for _, settings in pairs(tullaCTC.db.profile.rules) do
        if settings.theme == themeID then
            settings.theme = "default"
        end
    end

    tullaCTC:Refresh()
    self:TriggerEvent("OnThemeListChanged")
    return true
end

function Addon:ResetTheme(themeID)
    if not self:HasTheme(themeID) then
        return false
    end

    local theme = tullaCTC.db.profile.themes[themeID]
    local baseThemeID = theme.base
    local displayName = theme.displayName

    tullaCTC.db.profile.themes[themeID] = nil
    return self:CreateTheme(displayName or themeID, baseThemeID)
end

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

function Addon:GetSortedTextColors(themeID)
    return tullaCTC.db.profile.themes[themeID].textColors
end

function Addon:AddTextColorEntry(themeID, threshold, color)
    if not (threshold and threshold > 0) then
        return false
    end

    local entries = tullaCTC.db.profile.themes[themeID].textColors

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
    self:TriggerEvent("OnThemeColorsChanged", themeID)
    return true
end

function Addon:RemoveTextColorEntry(themeID, index)
    local entries = tullaCTC.db.profile.themes[themeID].textColors

    if index > 0 and index <= #entries then
        tremove(entries, index)
        tullaCTC:Refresh()
        self:TriggerEvent("OnThemeColorsChanged", themeID)
        return true
    end

    return false
end

function Addon:SetTextColorValue(themeID, index, color)
    local entry = tullaCTC.db.profile.themes[themeID].textColors[index]

    if entry.color ~= color then
        entry.color = color
        tullaCTC:Refresh()
        return true
    end

    return false
end

function Addon:SetTextColorThreshold(themeID, index, threshold)
    if not (threshold and threshold > 0) then
        return false
    end

    local entries = tullaCTC.db.profile.themes[themeID].textColors
    for _, entry in pairs(entries) do
        if entry.threshold == threshold then
            return false
        end
    end

    entries[index].threshold = threshold
    tullaCTC:Refresh()
    self:TriggerEvent("OnThemeColorsChanged", themeID)
    return true
end
