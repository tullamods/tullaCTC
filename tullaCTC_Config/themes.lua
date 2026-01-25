local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local LSM = LibStub('LibSharedMedia-3.0')
local tullaCTC = _G.tullaCTC

local function hexToRGBA(hex)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    local a = tonumber(hex:sub(7, 8), 16) / 255
    return r, g, b, a
end

local function rgbaToHex(r, g, b, a)
    return string.format("%02X%02X%02X%02X",
        Round(r * 255),
        Round(g * 255),
        Round(b * 255),
        Round(a * 255)
    )
end

local function createTextOptionsForTheme(theme, order)
    return {
        type = 'group',
        name = L.Typography,
        desc = L.TypographyDesc,
        order = order,
        args = {
            font = {
                type = 'group',
                name = L.TextFont,
                order = 0,
                inline = true,
                args = {
                    face = {
                        type = 'select',
                        name = L.FontFace,
                        order = 1,
                        width = 1.5,
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable('font'),
                        get = function()
                            for key, font in pairs(LSM:HashTable('font')) do
                                if theme.font == key then
                                    return key
                                end
                            end
                            return theme.font
                        end,
                        set = function(_, key)
                            theme.font = key
                            tullaCTC:Refresh()
                        end
                    },
                    size = {
                        type = 'range',
                        name = L.FontSize,
                        order = 3,
                        width = 'full',
                        min = 8,
                        softMax = 36,
                        step = 1,
                        get = function()
                            return theme.fontSize
                        end,
                        set = function(_, val)
                            theme.fontSize = val
                            tullaCTC:Refresh()
                        end
                    },
                    outline = {
                        type = 'select',
                        name = L.FontOutline,
                        order = 2,
                        get = function()
                            return theme.fontFlags or 'OUTLINE'
                        end,
                        set = function(_, val)
                            theme.fontFlags = val
                            tullaCTC:Refresh()
                        end,
                        values = {
                            [''] = L.Outline_NONE,
                            OUTLINE = L.Outline_OUTLINE,
                            THICKOUTLINE = L.Outline_THICKOUTLINE,
                            ['OUTLINE, MONOCHROME'] = L.Outline_OUTLINEMONOCHROME
                        }
                    }
                }
            },
            shadow = {
                type = 'group',
                name = L.TextShadow,
                inline = true,
                order = 10,
                args = {
                    color = {
                        type = 'color',
                        name = L.TextShadowColor,
                        order = 1,
                        width = 1.5,
                        hasAlpha = true,
                        get = function()
                            return hexToRGBA(theme.shadowColor or "00000000")
                        end,
                        set = function(_, r, g, b, a)
                            theme.shadowColor = rgbaToHex(r, g, b, a)
                            tullaCTC:Refresh()
                        end
                    },
                    x = {
                        order = 2,
                        type = 'range',
                        name = L.HorizontalOffset,
                        softMin = -4,
                        softMax = 4,
                        step = 1,
                        get = function()
                            return theme.shadowX or 0
                        end,
                        set = function(_, val)
                            theme.shadowX = val
                            tullaCTC:Refresh()
                        end
                    },
                    y = {
                        order = 3,
                        type = 'range',
                        name = L.VerticalOffset,
                        softMin = -4,
                        softMax = 4,
                        step = 1,
                        get = function()
                            return -(theme.shadowY or 0)
                        end,
                        set = function(_, val)
                            theme.shadowY = -val
                            tullaCTC:Refresh()
                        end
                    }
                }
            },
            position = {
                type = 'group',
                name = L.TextPosition,
                inline = true,
                order = 20,
                args = {
                    anchor = {
                        type = 'select',
                        width = 1.5,
                        name = L.Anchor,
                        order = 0,
                        get = function()
                            return theme.point or 'CENTER'
                        end,
                        set = function(_, val)
                            theme.point = val
                            tullaCTC:Refresh()
                        end,
                        values = {
                            TOPLEFT = L.Anchor_TOPLEFT,
                            TOP = L.Anchor_TOP,
                            TOPRIGHT = L.Anchor_TOPRIGHT,
                            LEFT = L.Anchor_LEFT,
                            CENTER = L.Anchor_CENTER,
                            RIGHT = L.Anchor_RIGHT,
                            BOTTOMLEFT = L.Anchor_BOTTOMLEFT,
                            BOTTOM = L.Anchor_BOTTOM,
                            BOTTOMRIGHT = L.Anchor_BOTTOMRIGHT
                        }
                    },
                    x = {
                        order = 2,
                        type = 'range',
                        name = L.HorizontalOffset,
                        softMin = -18,
                        softMax = 18,
                        step = 1,
                        get = function()
                            return theme.offsetX or 0
                        end,
                        set = function(_, val)
                            theme.offsetX = val
                            tullaCTC:Refresh()
                        end
                    },
                    y = {
                        order = 3,
                        type = 'range',
                        name = L.VerticalOffset,
                        softMin = -18,
                        softMax = 18,
                        step = 1,
                        get = function()
                            return -(theme.offsetY or 0)
                        end,
                        set = function(_, val)
                            theme.offsetY = -val
                            tullaCTC:Refresh()
                        end
                    }
                }
            }
        }
    }
end

local function createDisplayOptionsForTheme(theme, order)
    return {
        type = 'group',
        name = L.Display,
        desc = L.DisplayGroupDesc,
        order = order,
        args = {
            cooldownText = {
                type = 'group',
                name = L.CooldownText,
                inline = true,
                order = 100,
                args = {
                    forceShowText = {
                        type = 'toggle',
                        name = L.ForceShowText,
                        desc = L.ForceShowTextDesc,
                        order = 10,
                        width = 'full',
                        get = function()
                            return theme.forceShowText
                        end,
                        set = function(_, enable)
                            theme.forceShowText = enable
                            tullaCTC:Refresh()
                        end
                    },
                    minDuration = {
                        type = 'range',
                        name = L.MinDuration,
                        desc = L.MinDurationDesc,
                        width = 'full',
                        order = 20,
                        min = 0,
                        softMax = 60,
                        step = 1,
                        get = function()
                            return theme.minDuration or 3
                        end,
                        set = function(_, val)
                            theme.minDuration = val
                            tullaCTC:Refresh()
                        end
                    },
                    abbrevThreshold = {
                        type = 'range',
                        name = L.AbbrevThreshold,
                        desc = L.AbbrevThresholdDesc,
                        width = 'full',
                        order = 30,
                        min = 0,
                        softMax = 600,
                        step = 1,
                        get = function()
                            return theme.abbrevThreshold or 90
                        end,
                        set = function(_, val)
                            theme.abbrevThreshold = val
                            tullaCTC:Refresh()
                        end
                    }
                }
            }
        }
    }
end

-- Fixed thresholds for color curve (in seconds)
local COLOR_THRESHOLDS = {
    soon = 5,
    seconds = 60,
    minutes = 3600,
    hours = 14400,
}

local COLOR_DEFAULTS = {
    soon = "FF0000FF",
    seconds = "FFFF00FF",
    minutes = "FFFFFFFF",
    hours = "AAAAAAFF",
}

local function createColorOptionsForTheme(theme, order)
    local function getColorCurve()
        return theme.curves and theme.curves.color or {}
    end

    local function getColor(key)
        local threshold = COLOR_THRESHOLDS[key]
        local curve = getColorCurve()
        return curve[threshold] or COLOR_DEFAULTS[key]
    end

    local function setColor(key, hex)
        local threshold = COLOR_THRESHOLDS[key]
        theme.curves = theme.curves or {}
        theme.curves.color = theme.curves.color or {}
        theme.curves.color[threshold] = hex
        tullaCTC:Refresh()
    end

    return {
        type = 'group',
        name = L.Colors,
        desc = L.ColorsDesc,
        order = order,
        args = {
            soon = {
                type = 'color',
                name = L.ColorSoon,
                order = 10,
                hasAlpha = true,
                get = function()
                    return hexToRGBA(getColor("soon"))
                end,
                set = function(_, r, g, b, a)
                    setColor("soon", rgbaToHex(r, g, b, a))
                end
            },
            seconds = {
                type = 'color',
                name = L.ColorSeconds,
                order = 20,
                hasAlpha = true,
                get = function()
                    return hexToRGBA(getColor("seconds"))
                end,
                set = function(_, r, g, b, a)
                    setColor("seconds", rgbaToHex(r, g, b, a))
                end
            },
            minutes = {
                type = 'color',
                name = L.ColorMinutes,
                order = 30,
                hasAlpha = true,
                get = function()
                    return hexToRGBA(getColor("minutes"))
                end,
                set = function(_, r, g, b, a)
                    setColor("minutes", rgbaToHex(r, g, b, a))
                end
            },
            hours = {
                type = 'color',
                name = L.ColorHours,
                order = 40,
                hasAlpha = true,
                get = function()
                    return hexToRGBA(getColor("hours"))
                end,
                set = function(_, r, g, b, a)
                    setColor("hours", rgbaToHex(r, g, b, a))
                end
            }
        }
    }
end

local function addThemeOptions(owner, theme, id)
    local key = 'theme_' .. id

    local args = {
        display = createDisplayOptionsForTheme(theme, 100),
        text = createTextOptionsForTheme(theme, 200),
        colors = createColorOptionsForTheme(theme, 300),
        preview = {
            type = 'execute',
            order = 9000,
            name = L.Preview,
            func = function()
                Addon.PreviewDialog:SetTheme(id)
            end
        }
    }

    -- Add delete button for non-default themes
    if id ~= "default" then
        args.delete = {
            type = 'execute',
            order = 9100,
            name = L.DeleteTheme,
            desc = L.DeleteThemeDesc,
            confirm = function()
                return L.DeleteThemeConfirm:format(theme.displayName or id)
            end,
            func = function()
                tullaCTC.db.profile.themes[id] = nil
                Addon:RefreshThemeOptions()
                tullaCTC:Refresh()
            end
        }
    end

    owner.args[key] = {
        type = 'group',
        name = theme.displayName or id,
        order = id == "default" and 0 or 200,
        childGroups = 'tab',
        args = args
    }
end

local ThemeOptions = {
    type = 'group',
    name = L.Themes,
    args = {
        description = {
            type = 'description',
            name = L.ThemesDesc,
            order = 0
        },
        add = {
            type = 'input',
            order = 1,
            name = L.CreateTheme,
            desc = L.CreateThemeDesc,
            width = 'double',
            set = function(_, val)
                val = strtrim(val)
                if val == '' then
                    return
                end

                local key = 'custom_' .. val
                if rawget(tullaCTC.db.profile.themes, key) then
                    return
                end

                tullaCTC.db.profile.themes[key].displayName = val
                Addon:RefreshThemeOptions()
            end,
            validate = function(_, val)
                val = strtrim(val)
                return not (val == "" or rawget(tullaCTC.db.profile.themes, 'custom_' .. val))
            end
        }
    }
}

function Addon:RefreshThemeOptions()
    for key in pairs(ThemeOptions.args) do
        if key:match('^theme_') then
            ThemeOptions.args[key] = nil
        end
    end

    local themes = tullaCTC.db.profile.themes
    for id, theme in pairs(themes) do
        if id ~= '**' then
            addThemeOptions(ThemeOptions, theme, id)
        end
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("tullaCTC")
end

Addon:RefreshThemeOptions()
Addon.ThemeOptions = ThemeOptions
