-- Utility functions for tullaCTC

local _, Addon = ...

--------------------------------------------------------------------------------
-- Color Utilities
--------------------------------------------------------------------------------

Addon.CreateColor = setmetatable({}, {
    __mode = "v",
    __call = function(self, hex)
        if type(hex) ~= "string" or (#hex ~= 8 and #hex ~= 6) then
            return nil
        end

        local color = self[hex]
        if not color then
            if #hex == 8 then
                color = CreateColorFromRGBAHexString(hex)
            elseif #hex == 6 then
                color = CreateColorFromHexString(hex)
            end

            self[hex] = color
        end
        return color
    end
})

function Addon.HexToRGBA(hex)
    local color = Addon.CreateColor(hex)
    if color then
        return color:GetRGBA()
    end
end

function Addon.RGBAToHex(r, g, b, a)
    return ("%02X%02X%02X%02X"):format(
        Round(r * 255),
        Round(g * 255),
        Round(b * 255),
        Round(a * 255)
    )
end
