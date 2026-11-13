---@type string, simpleAlts
local ADDON_NAME, simpleAlts = ...

local colors  = simpleAlts.colors
local fonts   = simpleAlts.fonts

local DEFAULT_WIDTH  = 1200
local DEFAULT_HEIGHT = 640
local MIN_WIDTH      = 600
local MIN_HEIGHT     = 400
local MAX_WIDTH      = 1600
local MAX_HEIGHT     = 900

---@param addonName string
local function buildOptionsFrame(_, addonName)
	if addonName ~= ADDON_NAME then return end

	-- Main frame
	local OptionsFrame = CreateFrame('Frame', 'SimpleAlts', UIParent)
	simpleAlts.OptionsFrame = OptionsFrame
	OptionsFrame:SetFrameStrata('HIGH')
	OptionsFrame:SetSize(SimpleAltsDB.OptionsFrame.w or DEFAULT_WIDTH, SimpleAltsDB.OptionsFrame.h or DEFAULT_HEIGHT)
	OptionsFrame:SetResizable(true)
	OptionsFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
	OptionsFrame:SetPoint(SimpleAltsDB.OptionsFrame.point or 'CENTER', UIParent, SimpleAltsDB.OptionsFrame.relativePoint or 'CENTER', SimpleAltsDB.OptionsFrame.x or 0, SimpleAltsDB.OptionsFrame.y or 0)
	simpleAlts.CreateFlatBackdrop(OptionsFrame, 0.8)

	tinsert(UISpecialFrames, 'SimpleAlts')
	OptionsFrame:SetMovable(true)
	OptionsFrame:EnableMouse(true)
	OptionsFrame:RegisterForDrag('LeftButton')
	OptionsFrame:SetScript('OnDragStart', function(self) self:StartMoving() end)
	OptionsFrame:SetScript('OnDragStop', function(self)
		local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
		SimpleAltsDB.OptionsFrame.point         = point
		SimpleAltsDB.OptionsFrame.relativePoint = relativePoint
		SimpleAltsDB.OptionsFrame.x             = xOffset
		SimpleAltsDB.OptionsFrame.y             = yOffset
		self:StopMovingOrSizing()
	end)
	OptionsFrame:SetScript('OnSizeChanged', function(_, w, h)
		SimpleAltsDB.OptionsFrame.w = w
		SimpleAltsDB.OptionsFrame.h = h
	end)
	OptionsFrame:Hide()

	-- Title text
	local TitleText = OptionsFrame:CreateFontString()
	TitleText:SetFontObject(fonts.title)
	TitleText:SetText(colors.primaryColor.colorStr .. 'Simple|r Alts')
	TitleText:SetPoint('TOPLEFT', OptionsFrame, 'TOPLEFT', 3, -8)

	-- Version text
	local VersionText = OptionsFrame:CreateFontString()
	VersionText:SetFontObject(fonts.subHeader)
	VersionText:SetText(C_AddOns.GetAddOnMetadata(ADDON_NAME, 'Version'))
	VersionText:SetPoint('BOTTOMLEFT', TitleText, 'BOTTOMRIGHT', 3, 3)

	-- Close button
	simpleAlts.CreateXButton(14, OptionsFrame, 'TOPRIGHT', OptionsFrame, 'TOPRIGHT', 0, 0, nil, function() OptionsFrame:Hide() end)

	-- Resize button
	local ResizeButton = simpleAlts.CreateResizeButton(OptionsFrame)

	ResizeButton:SetScript('OnMouseDown', function(self, button)
		if button == 'LeftButton' then
			local left, bottom, _, height = OptionsFrame:GetRect()
			OptionsFrame:ClearAllPoints()
			OptionsFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', left, bottom + height)

			OptionsFrame:StartSizing('BOTTOMRIGHT')
			self:GetHighlightTexture():Hide()
		end
	end)
	ResizeButton:SetScript('OnMouseUp', function(self)
		OptionsFrame:StopMovingOrSizing()
		self:GetHighlightTexture():Show()

		local point, _, relativePoint, xOffset, yOffset = OptionsFrame:GetPoint()
		SimpleAltsDB.OptionsFrame.point         = point
		SimpleAltsDB.OptionsFrame.relativePoint = relativePoint
		SimpleAltsDB.OptionsFrame.x             = xOffset
		SimpleAltsDB.OptionsFrame.y             = yOffset
	end)

	-- Header row

	-- Character data rows
	local sorted = {}
	for name, data in pairs(SimpleAltsDB.characters) do sorted[#sorted + 1] = {name = name, data = data} end
	table.sort(sorted, function(a, b) return a.data.index < b.data.index end)

	local previous
  for _, entry in ipairs(sorted) do
    local Row = simpleAlts.AcquireRow(entry.name, entry.data)

    if previous then
      Row:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, -2)
      Row:SetPoint('TOPRIGHT', previous, 'BOTTOMRIGHT', 0, -2)
    else
      Row:SetPoint('TOPLEFT', OptionsFrame, 'TOPLEFT', 4, -30)
      Row:SetPoint('TOPRIGHT', OptionsFrame, 'TOPRIGHT', -4, -30)
    end
    Row:Show()
    previous = Row
  end

	function simpleAlts.ToggleOptions()
		local isShown = OptionsFrame:IsShown()
		OptionsFrame:SetShown(not isShown)
	end

	simpleAlts.UnregisterEventHandler('ADDON_LOADED', buildOptionsFrame)
end

simpleAlts.RegisterEventHandler('ADDON_LOADED', buildOptionsFrame)