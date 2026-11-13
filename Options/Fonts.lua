---@type string, simpleAlts
local _, simpleAlts = ...

local font   = simpleAlts.defaultFont
local colors = simpleAlts.colors

---@type FontFlag
local flags = 'OUTLINE, SLUG'

local SimpleAltsFontTitle = CreateFont('SimpleAltsFontTitle')
SimpleAltsFontTitle:SetFont(font, 30, flags)
SimpleAltsFontTitle:SetTextColor(1, 1, 1, 1)

local SimpleAltsFontHeader = CreateFont('SimpleAltsFontHeader')
SimpleAltsFontHeader:SetFont(font, 20, flags)
SimpleAltsFontHeader:SetTextColor(colors.primaryColor.r, colors.primaryColor.g, colors.primaryColor.b, 1)

local SimpleAltsFontSubHeader = CreateFont('SimpleAltsFontSubHeader')
SimpleAltsFontSubHeader:SetFont(font, 14, flags)
SimpleAltsFontSubHeader:SetTextColor(0.7, 0.7, 0.7, 1)

local SimpleAltsFontNav = CreateFont('SimpleAltsFontNav')
SimpleAltsFontNav:SetFont(font, 16, flags)
SimpleAltsFontNav:SetTextColor(0.8, 0.8, 0.8, 1)

local SimpleAltsFontBody = CreateFont('SimpleAltsFontBody')
SimpleAltsFontBody:SetFont(font, 14, flags)
SimpleAltsFontBody:SetTextColor(0.9, 0.9, 0.9, 1)

local SimpleAltsEditBox = CreateFont('SimpleAltsEditBox')
SimpleAltsEditBox:SetFont(font, 14, flags)
SimpleAltsEditBox:SetTextColor(1, 1, 1, 1)

simpleAlts.fonts = {
	title     = SimpleAltsFontTitle,
	header    = SimpleAltsFontHeader,
	subHeader = SimpleAltsFontSubHeader,
	nav       = SimpleAltsFontNav,
	body      = SimpleAltsFontBody,
	editbox   = SimpleAltsEditBox,
}