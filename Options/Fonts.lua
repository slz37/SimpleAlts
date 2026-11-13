---@type string, simpleAlts
local _, simpleAlts = ...

local font   = simpleAlts.defaultFont
local colors = simpleAlts.colors

---@type FontFlag
local flags = 'OUTLINE, SLUG'

local SimpleAltsFontTitle = CreateFont('SimpleAltsFontTitle')
SimpleAltsFontTitle:SetFont(font, 30, flags)
SimpleAltsFontTitle:SetTextColor(1, 1, 1, 1)

local SimpleAltsFontSubtitle = CreateFont('SimpleAltsFontSubtitle')
SimpleAltsFontSubtitle:SetFont(font, 14, flags)
SimpleAltsFontSubtitle:SetTextColor(0.7, 0.7, 0.7, 1)

local SimpleAltsFontHeader = CreateFont('SimpleAltsFontHeader')
SimpleAltsFontHeader:SetFont(font, 14, flags)
SimpleAltsFontHeader:SetTextColor(0.9, 0.9, 0.9, 1)

local SimpleAltsFontBody = CreateFont('SimpleAltsFontBody')
SimpleAltsFontBody:SetFont(font, 12, flags)
SimpleAltsFontBody:SetTextColor(0.9, 0.9, 0.9, 1)

simpleAlts.fonts = {
	title    = SimpleAltsFontTitle,
	subTitle = SimpleAltsFontSubtitle,
	header   = SimpleAltsFontHeader,
	body     = SimpleAltsFontBody,
}