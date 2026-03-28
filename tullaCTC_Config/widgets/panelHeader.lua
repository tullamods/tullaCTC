local _, Addon = ...

local HEADER_HEIGHT = 50

function Addon:CreatePanelHeader(container, title)
    local header = CreateFrame("Frame", nil, container)

    header:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    header:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", 0, -HEADER_HEIGHT)

    local titleText = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    titleText:SetPoint("TOPLEFT", header, "TOPLEFT", 7, -22)
    titleText:SetText(title)

    local divider = header:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("Options_HorizontalDivider", TextureKitConstants.UseAtlasSize)
    divider:SetPoint("TOP", header, "TOP", 0, -HEADER_HEIGHT)

    return header
end
