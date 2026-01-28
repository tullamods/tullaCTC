local _, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale('tullaCTC', true)
local LSM = LibStub('LibSharedMedia-3.0')

-- Track the currently selected theme
local selectedThemeId = "default"

local function getSelectedThemeId()
    return selectedThemeId
end

local function setSelectedThemeId(id)
    if Addon:ThemeExists(id) then
        selectedThemeId = id
        return true
    end
    return false
end

local function getSelectedTheme()
    return Addon:GetTheme(selectedThemeId)
end

local function getThemeValues()
    local values = {}
    for id, theme in pairs(Addon:GetThemes()) do
        if id ~= '**' then
            values[id] = theme.displayName or id
        end
    end
    return values
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
                        order = 100,
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable('font'),
                        get = function()
                            return theme.font
                        end,
                        set = function(_, key)
                            Addon:SetThemeProperty(theme, 'font', key)
                        end,
                    },
                    outline = Addon:CreateSelectOption(theme, 'fontFlags', {
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
                    size = Addon:CreateRangeOption(theme, 'fontSize', {
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
                    color = Addon:CreateColorOption(theme, 'shadowColor', {
                        name = L.TextShadowColor,
                        order = 1,
                        width = 1.5,
                        default = "00000000"
                    }),
                    x = Addon:CreateRangeOption(theme, 'shadowX', {
                        name = L.HorizontalOffset,
                        order = 2,
                        softMin = -4,
                        softMax = 4,
                        width = 'full'
                    }),
                    y = Addon:CreateRangeOption(theme, 'shadowY', {
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
                    anchor = Addon:CreateSelectOption(theme, 'point', {
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
                    x = Addon:CreateRangeOption(theme, 'offsetX', {
                        name = L.HorizontalOffset,
                        order = 2,
                        softMin = -18,
                        softMax = 18,
                        width = 'full'
                    }),
                    y = Addon:CreateRangeOption(theme, 'offsetY', {
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

local function createGeneralOptionsForTheme(theme, order)
    return {
        type = 'group',
        name = L.General,
        order = order,
        args = {
            enabled = Addon:CreateToggleOption(theme, 'enabled', {
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
                    themeText = Addon:CreateToggleOption(theme, 'themeText', {
                        name = L.ThemeText,
                        desc = L.ThemeTextDesc,
                        order = 0,
                        width = 'full'
                    }),

                    drawText = Addon:CreateDrawStateOption(theme, 'drawText', {
                        name = L.DrawText,
                        desc = L.DrawTextDesc,
                        order = 10,
                    }),
                    minDuration = Addon:CreateRangeOption(theme, 'minDuration', {
                        name = L.MinDuration,
                        desc = L.MinDurationDesc,
                        order = 20,
                        min = 0,
                        softMax = 60,
                        default = 3,
                        width = 'full'
                    }),
                    abbrevThreshold = Addon:CreateRangeOption(theme, 'abbrevThreshold', {
                        name = L.AbbrevThreshold,
                        desc = L.AbbrevThresholdDesc,
                        order = 30,
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
                    themeCooldown = Addon:CreateToggleOption(theme, 'themeCooldown', {
                        name = L.ThemeCooldown,
                        desc = L.ThemeCooldownDesc,
                        order = 0,
                        width = 'full'
                    }),

                    drawSwipe = Addon:CreateDrawStateOption(theme, 'drawSwipe', {
                        name = L.DrawSwipe,
                        desc = L.DrawSwipeDesc,
                        order = 100
                    }),

                    drawEdge = Addon:CreateDrawStateOption(theme, 'drawEdge', {
                        name = L.DrawEdge,
                        desc = L.DrawEdgeDesc,
                        order = 120,
                    }),

                    drawBling = Addon:CreateDrawStateOption(theme, 'drawBling', {
                        name = L.DrawBling,
                        desc = L.DrawBlingDesc,
                        order = 130
                    }),

                    reverse = Addon:CreateDrawStateOption(theme, 'reverse', {
                        name = L.Reverse,
                        desc = L.ReverseDesc,
                        order = 140
                    })
                }
            }
        }
    }
end

local function createColorOptionsForTheme(theme, order)
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
                            if threshold and Addon:AddTextColor(theme, threshold) then
                                Addon:RefreshThemeOptions()
                            end
                        end,
                        validate = function(_, val)
                            return Addon:ValidateThreshold(val)
                        end
                    }
                }
            }
        }
    }

    local textColors = Addon:GetTextColors(theme)
    local prevThreshold = nil

    for i, entry in ipairs(textColors) do
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
                        local textColor = Addon:GetTextColorEntry(theme, i)
                        if textColor then
                            return Addon:FormatThreshold(textColor.threshold)
                        end
                        return ""
                    end,
                    set = function(_, val)
                        local newThreshold = Addon:ParseThreshold(val)
                        if newThreshold and Addon:SetTextColorThreshold(theme, i, newThreshold) then
                            Addon:RefreshThemeOptions()
                        end
                    end,
                    validate = function(_, val)
                        return Addon:ValidateThreshold(val)
                    end
                },
                color = {
                    type = 'color',
                    name = L.TextColor,
                    order = 2,
                    width = 1,
                    hasAlpha = true,
                    get = function()
                        local textColor = Addon:GetTextColorEntry(theme, i)
                        if textColor then
                            return Addon:HexToRGBA(textColor.color)
                        end
                        return 1, 1, 1, 1
                    end,
                    set = function(_, r, g, b, a)
                        Addon:SetTextColorValue(theme, i, r, g, b, a)
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
                        if Addon:RemoveTextColor(theme, i) then
                            Addon:RefreshThemeOptions()
                        end
                    end
                }
            }
        }

        prevThreshold = threshold
    end

    return options
end

local function addSelectedThemeOptions(owner)
    local theme = getSelectedTheme()
    if not theme then return end

    owner.args.display = createGeneralOptionsForTheme(theme, 100)
    owner.args.text = createTextOptionsForTheme(theme, 200)
    owner.args.colors = createColorOptionsForTheme(theme, 300)
    owner.args.preview = {
        type = 'execute',
        order = 9000,
        name = L.Preview,
        func = function()
            Addon.PreviewDialog:SetTheme(selectedThemeId)
        end
    }
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
                    width = 1.5,
                    values = getThemeValues,
                    get = getSelectedThemeId,
                    set = function(_, id)
                        if setSelectedThemeId(id) then
                            Addon:RefreshThemeOptions()
                        end
                    end
                }
            }
        },
        manage = {
            type = 'group',
            name = L.ManageThemes,
            order = 500,
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
                            local newId = Addon:CreateTheme(val)
                            if newId then
                                setSelectedThemeId(newId)
                                Addon:RefreshThemeOptions()
                            end
                        end
                    end,
                    validate = function(_, val)
                        val = strtrim(val)
                        return val ~= "" and not Addon:ThemeExists('custom_' .. val)
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
                            local newId = Addon:CreateTheme(val, getSelectedThemeId())
                            if newId then
                                setSelectedThemeId(newId)
                                Addon:RefreshThemeOptions()
                            end
                        end
                    end,
                    validate = function(_, val)
                        val = strtrim(val)
                        return val ~= "" and not Addon:ThemeExists('custom_' .. val)
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
                        return selectedThemeId == "default"
                    end,
                    get = function()
                        local theme = getSelectedTheme()
                        return theme and theme.displayName or selectedThemeId
                    end,
                    set = function(_, val)
                        val = strtrim(val)
                        if val ~= '' and Addon:RenameTheme(selectedThemeId, val) then
                            Addon:RefreshThemeOptions()
                        end
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
                    confirm = function()
                        local theme = getSelectedTheme()
                        return L.ResetThemeConfirm:format(theme and theme.displayName or selectedThemeId)
                    end,
                    func = function()
                        if Addon:ResetTheme(selectedThemeId) then
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
                        return selectedThemeId == "default"
                    end,
                    confirm = function()
                        local theme = getSelectedTheme()
                        return L.DeleteThemeConfirm:format(theme and theme.displayName or selectedThemeId)
                    end,
                    func = function()
                        if Addon:DeleteTheme(selectedThemeId) then
                            setSelectedThemeId("default")
                            Addon:RefreshThemeOptions()
                        end
                    end
                }
            }
        }
    }
}

local STATIC_GROUPS = { toolbar = true, manage = true }

function Addon:RefreshThemeOptions()
    -- Clear existing theme options (preserve static groups)
    for key in pairs(ThemeOptions.args) do
        if not STATIC_GROUPS[key] then
            ThemeOptions.args[key] = nil
        end
    end

    -- Add options for the selected theme
    addSelectedThemeOptions(ThemeOptions)

    LibStub("AceConfigRegistry-3.0"):NotifyChange("tullaCTC")
end

Addon:RefreshThemeOptions()
Addon.ThemeOptions = ThemeOptions
