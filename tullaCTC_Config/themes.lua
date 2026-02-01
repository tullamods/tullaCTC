local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local LSM = LibStub('LibSharedMedia-3.0')
local tullaCTC = _G.tullaCTC

-- Track the currently selected theme
local selectedThemeId = "default"

local function getSelectedThemeID()
    return selectedThemeId
end

local function setSelectedThemeId(id)
    if Addon:HasTheme(id) then
        selectedThemeId = id
        return true
    end
    return false
end

local function createTextOptionsForTheme(themeID, order)
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
                        order = 100,
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable('font'),
                        get = function()
                            return tullaCTC.db.profile.themes[themeID].font
                        end,
                        set = function(_, key)
                            Addon:SetThemeProperty(themeID, 'font', key)
                        end,
                    },
                    outline = Addon:CreateSelectOption(themeID, 'fontFlags', {
                        name = L.FontOutline,
                        order = 200,
                        default = 'OUTLINE',
                        values = {
                            [''] = L.Outline_NONE,
                            OUTLINE = L.Outline_OUTLINE,
                            THICKOUTLINE = L.Outline_THICKOUTLINE,
                            ['OUTLINE, MONOCHROME'] = L.Outline_OUTLINEMONOCHROME
                        }
                    }),
                    size = Addon:CreateRangeOption(themeID, 'fontSize', {
                        name = L.FontSize,
                        order = 300,
                        width = 'full',
                        min = 0,
                        softMax = 36
                    }),
                }
            },
            shadow = {
                type = 'group',
                name = L.TextShadow,
                inline = true,
                order = 10,
                args = {
                    color = Addon:CreateColorOption(themeID, 'shadowColor', {
                        name = L.TextShadowColor,
                        order = 1,
                        width = 1.5,
                        default = "00000000"
                    }),
                    x = Addon:CreateRangeOption(themeID, 'shadowX', {
                        name = L.HorizontalOffset,
                        order = 2,
                        softMin = -4,
                        softMax = 4,
                        width = 'full'
                    }),
                    y = Addon:CreateRangeOption(themeID, 'shadowY', {
                        name = L.VerticalOffset,
                        order = 3,
                        softMin = -4,
                        softMax = 4,
                        invert = true,
                        width = 'full'
                    })
                }
            },
            position = {
                type = 'group',
                name = L.TextPosition,
                inline = true,
                order = 20,
                args = {
                    anchor = Addon:CreateSelectOption(themeID, 'point', {
                        name = L.Anchor,
                        order = 0,
                        width = 1.5,
                        default = 'CENTER',
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
                    }),
                    x = Addon:CreateRangeOption(themeID, 'offsetX', {
                        name = L.HorizontalOffset,
                        order = 2,
                        softMin = -18,
                        softMax = 18,
                        width = 'full'
                    }),
                    y = Addon:CreateRangeOption(themeID, 'offsetY', {
                        name = L.VerticalOffset,
                        order = 3,
                        softMin = -18,
                        softMax = 18,
                        invert = true,
                        width = 'full'
                    })
                }
            }
        }
    }
end

local function createGeneralOptionsForTheme(themeID, order)
    return {
        type = 'group',
        name = L.General,
        order = order,
        args = {
            enabled = Addon:CreateToggleOption(themeID, 'enabled', {
                name = L.ThemeEnabled,
                desc = L.ThemeEnabledDesc,
                order = 0,
                width = 'full'
            }),
            textOptions = {
                type = 'group',
                name = L.CooldownText,
                inline = true,
                order = 100,
                args = {
                    themeText = Addon:CreateToggleOption(themeID, 'themeText', {
                        name = L.ThemeText,
                        desc = L.ThemeTextDesc,
                        order = 0,
                        width = 'full'
                    }),

                    drawText = Addon:CreateDrawStateOption(themeID, 'drawText', {
                        name = L.DrawText,
                        desc = L.DrawTextDesc,
                        order = 10,
                    }),

                    drawEdge = Addon:CreateDrawStateOption(themeID, 'useAuraDisplayTime', {
                        name = L.UseAuraDisplayTime,
                        desc = L.UseAuraDisplayTimeDesc,
                        order = 20,
                    }),

                    minDuration = Addon:CreateRangeOption(themeID, 'minDuration', {
                        name = L.MinDuration,
                        desc = L.MinDurationDesc,
                        order = 30,
                        min = 0,
                        softMax = 60,
                        default = 3,
                        width = 'full'
                    }),

                    abbrevThreshold = Addon:CreateRangeOption(themeID, 'abbrevThreshold', {
                        name = L.AbbrevThreshold,
                        desc = L.AbbrevThresholdDesc,
                        order = 40,
                        min = 0,
                        softMax = 600,
                        default = 90,
                        width = 'full'
                    })
                }
            },
            cooldownOptions = {
                type = 'group',
                name = L.Cooldown,
                desc = L.CooldownDesc,
                inline = true,
                order = 200,
                args = {
                    themeCooldown = Addon:CreateToggleOption(themeID, 'themeCooldown', {
                        name = L.ThemeCooldown,
                        desc = L.ThemeCooldownDesc,
                        order = 0,
                        width = 'full'
                    }),

                    drawSwipe = Addon:CreateDrawStateOption(themeID, 'drawSwipe', {
                        name = L.DrawSwipe,
                        desc = L.DrawSwipeDesc,
                        order = 100
                    }),

                    drawEdge = Addon:CreateDrawStateOption(themeID, 'drawEdge', {
                        name = L.DrawEdge,
                        desc = L.DrawEdgeDesc,
                        order = 120,
                    }),

                    drawBling = Addon:CreateDrawStateOption(themeID, 'drawBling', {
                        name = L.DrawBling,
                        desc = L.DrawBlingDesc,
                        order = 130
                    }),

                    reverse = Addon:CreateDrawStateOption(themeID, 'reverse', {
                        name = L.Reverse,
                        desc = L.ReverseDesc,
                        order = 140
                    }),

                    themeSwipeColor = Addon:CreateToggleOption(themeID, 'themeSwipeColor', {
                        name = L.ThemeSwipeColor,
                        order = 150
                    }),

                    swipeColor = Addon:CreateColorOption(themeID, 'swipeColor', {
                        name = L.SwipeColor,
                        desc = L.SwipeColorDesc,
                        order = 160,
                        default = "00000000"
                    }),
                }
            }
        }
    }
end

local function createColorOptionsForTheme(themeID, order)
    local theme = tullaCTC.db.profile.themes[themeID]

    local options = {
        type = 'group',
        name = L.Colors,
        desc = L.ColorsDesc,
        order = order,
        args = {
            description = {
                type = 'description',
                name = L.ColorsDescription,
                order = 0
            },
            addThreshold = {
                type = 'group',
                name = L.AddColorThreshold,
                inline = true,
                order = 1,
                args = {
                    newThreshold = {
                        type = 'input',
                        name = L.NewThresholdValue,
                        desc = L.NewThresholdValueDesc,
                        order = 1,
                        width = 1.2,
                        get = function() return "" end,
                        set = function(_, val)
                            local threshold = Addon:ParseThreshold(val)
                            if Addon:AddTextColorEntry(theme, threshold) then
                                Addon:RefreshThemeOptions()
                            end
                        end,
                        validate = function(_, val)
                            return Addon:ParseThreshold(val) ~= nil
                        end
                    }
                }
            }
        }
    }

    local entries = Addon:GetSortedTextColors(theme)
    local prevThreshold = nil

    for i, entry in ipairs(entries) do
        local threshold = entry.threshold

        options.args["color_" .. i] = {
            type = 'group',
            name = Addon:FormatEffectiveRange(prevThreshold, threshold),
            inline = true,
            order = 10 + i,
            args = {
                threshold = {
                    type = 'input',
                    name = L.Threshold,
                    desc = L.ThresholdDesc,
                    order = 1,
                    width = 0.8,
                    get = function()
                        return tostring(entry.threshold)
                    end,
                    set = function(_, val)
                        local threshold = Addon:ParseThreshold(val)
                        if Addon:SetTextColorThreshold(theme, i, threshold) then
                            Addon:RefreshThemeOptions()
                        end
                    end,
                    validate = function(_, val)
                        return Addon:ParseThreshold(val) ~= nil
                    end
                },
                color = {
                    type = 'color',
                    name = L.TextColor,
                    order = 2,
                    width = 1,
                    hasAlpha = true,
                    get = function()
                        return Addon.HexToRGBA(entry.color)
                    end,
                    set = function(_, r, g, b, a)
                        local color = Addon.RGBAToHex(r, g, b, a)
                        if Addon:SetTextColorValue(theme, i, color) then
                            Addon:RefreshThemeOptions()
                        end
                    end
                },
                remove = {
                    type = 'execute',
                    name = L.RemoveThreshold,
                    order = 3,
                    width = 0.6,
                    confirm = true,
                    confirmText = L.RemoveThresholdConfirm,
                    func = function()
                        if Addon:RemoveTextColorEntry(theme, i) then
                            Addon:RefreshThemeOptions()
                        end
                    end
                }
            }
        }

        prevThreshold = threshold
    end

    -- add default color control (shown last, for durations above all thresholds)
    local lastThreshold = prevThreshold
    options.args["defaultColor"] = {
        type = 'group',
        name = Addon:FormatDefaultColorRange(lastThreshold),
        inline = true,
        order = 1000,
        args = {
            drawSwipe = Addon:CreateColorOption(themeID, 'defaultTextColor', {
                name = L.TextColor,
                order = 1,
                width = 1,
            })
        }
    }

    return options
end

local function createMangementOptionsForTheme(themeID, order)
    local options = {
        type = 'group',
        name = L.ManageThemes,
        order = order,
        args = {
            create = {
                type = 'input',
                order = 100,
                name = L.CreateTheme,
                desc = L.CreateThemeDesc,
                get = function() return "" end,
                set = function(_, val)
                    val = strtrim(val)
                    if val ~= '' then
                        local newThemeID = Addon:CreateTheme(val)
                        if newThemeID then
                            setSelectedThemeId(newThemeID)
                            Addon:RefreshThemeOptions()
                        end
                    end
                end,
                validate = function(_, val)
                    val = strtrim(val)
                    return val ~= "" and not Addon:HasTheme('custom_' .. val)
                end
            },

            copy = {
                type = 'input',
                name = L.CopyTheme,
                desc = L.CopyThemeDesc,
                order = 200,
                get = function() return "" end,
                set = function(_, val)
                    val = strtrim(val)
                    if val ~= '' then
                        local newThemeID = Addon:CreateTheme(val, themeID)
                        if newThemeID then
                            setSelectedThemeId(newThemeID)
                            Addon:RefreshThemeOptions()
                        end
                    end
                end,
                validate = function(_, val)
                    val = strtrim(val)
                    return val ~= "" and not Addon:HasTheme('custom_' .. val)
                end
            },

            modifySection = {
                type = 'header',
                name = '',
                order = 250
            },

            rename = {
                type = 'input',
                name = L.RenameTheme,
                desc = L.RenameThemeDesc,
                order = 300,
                disabled = function()
                    return themeID == "default"
                end,
                get = function()
                    return ""
                end,
                set = function(_, val)
                    val = strtrim(val)
                    if val ~= '' and not Addon:HasTheme('custom_' .. val) then
                        Addon:SetThemeProperty(themeID, 'displayName', val)
                        Addon:RefreshThemeOptions()
                    end
                end,
                validate = function(_, val)
                    val = strtrim(val)
                    return val ~= "" and not Addon:HasTheme('custom_' .. val)
                end
            },

            dangerSection = {
                type = 'header',
                name = '',
                order = 350
            },

            reset = {
                type = 'execute',
                name = L.ResetTheme,
                desc = L.ResetThemeDesc,
                order = 400,
                func = function()
                    if Addon:ResetTheme(themeID) then
                        Addon:RefreshThemeOptions()
                    end
                end
            },

            delete = {
                type = 'execute',
                name = L.DeleteTheme,
                desc = L.DeleteThemeDesc,
                order = 500,
                disabled = function()
                    return themeID == "default"
                end,
                func = function()
                    if Addon:DeleteTheme(themeID) then
                        setSelectedThemeId("default")
                        Addon:RefreshThemeOptions()
                    end
                end
            }
        }
    }

    return options
end

local function addSelectedThemeOptions(options, themeID)
    options.args.display = createGeneralOptionsForTheme(themeID, 100)
    options.args.text = createTextOptionsForTheme(themeID, 200)
    options.args.colors = createColorOptionsForTheme(themeID, 300)
    options.args.manage = createMangementOptionsForTheme(themeID, 400)
end

local ThemeOptions = {
    type = 'group',
    name = L.Themes,
    args = {
        toolbar = {
            type = 'group',
            name = "",
            inline = true,
            order = 0,
            args = {
                theme = {
                    type = 'select',
                    name = L.SelectTheme,
                    order = 1,
                    values = function ()
                        local values = {}
                        for id, theme in pairs(tullaCTC.db.profile.themes) do
                            values[id] = theme.displayName or rawget(L, 'Theme_' .. id) or id
                        end
                        return values
                    end,
                    sorting = function()
                        local keys = {}
                        for id in pairs(tullaCTC.db.profile.themes) do
                            keys[#keys + 1] = id
                        end
                        table.sort(keys, function(a, b)
                            local themeA = tullaCTC.db.profile.themes[a]
                            local themeB = tullaCTC.db.profile.themes[b]
                            local nameA = themeA.displayName or rawget(L, 'Theme_' .. a) or a
                            local nameB = themeB.displayName or rawget(L, 'Theme_' .. b) or b
                            return nameA < nameB
                        end)
                        return keys
                    end,
                    get = getSelectedThemeID,
                    set = function(_, id)
                        if setSelectedThemeId(id) then
                            Addon:RefreshThemeOptions()
                        end
                    end
                },

                review = {
                    type = 'execute',
                    order = 9000,
                    name = L.Preview,
                    func = function()
                        Addon.PreviewDialog:SetTheme(getSelectedThemeID())
                    end
                }
            }
        }
    }
}

local STATIC_GROUPS = { toolbar = true }

function Addon:RefreshThemeOptions()
    -- Clear existing theme options (preserve static groups)
    for key in pairs(ThemeOptions.args) do
        if not STATIC_GROUPS[key] then
            ThemeOptions.args[key] = nil
        end
    end

    -- Add options for the selected theme
    addSelectedThemeOptions(ThemeOptions, getSelectedThemeID())

    LibStub("AceConfigRegistry-3.0"):NotifyChange("tullaCTC")
end

Addon:RefreshThemeOptions()
Addon.ThemeOptions = ThemeOptions
