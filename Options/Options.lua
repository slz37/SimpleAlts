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
local SCROLL_SIZE    = 6
local SCROLL_STEP    = 40

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
	OptionsFrame:SetScript('OnShow', function() simpleAlts.RefreshAll() end)
	OptionsFrame:Hide()

	-- Title text
	local TitleText = OptionsFrame:CreateFontString()
	TitleText:SetFontObject(fonts.title)
	TitleText:SetText(colors.primaryColor.colorStr .. 'Simple|r Alts')
	TitleText:SetPoint('TOPLEFT', OptionsFrame, 'TOPLEFT', 3, -8)

	-- Version text
	local VersionText = OptionsFrame:CreateFontString()
	VersionText:SetFontObject(fonts.subTitle)
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

	-- Scroll frame
	local ScrollFrame = CreateFrame('ScrollFrame', nil, OptionsFrame)
	ScrollFrame:SetPoint('TOPLEFT', OptionsFrame, 'TOPLEFT', 4, -40)
	ScrollFrame:SetPoint('BOTTOMRIGHT', OptionsFrame, 'BOTTOMRIGHT', -(4 + SCROLL_SIZE + 2), 4 + SCROLL_SIZE + 2)

	local Content = CreateFrame('Frame', nil, ScrollFrame)
	ScrollFrame:SetScrollChild(Content)
	simpleAlts.ColParent = Content

	-- Scroll bars
	local VScroll = CreateFrame('Slider', nil, OptionsFrame)
	VScroll:SetOrientation('VERTICAL')
	VScroll:SetPoint('TOPRIGHT', OptionsFrame, 'TOPRIGHT', -4, -40)
	VScroll:SetPoint('BOTTOMRIGHT', OptionsFrame, 'BOTTOMRIGHT', -4, 20)
	VScroll:SetMinMaxValues(0, 0)
	VScroll:SetValue(0)
	simpleAlts.StyleScrollBar(VScroll, 'VERTICAL')
	VScroll:GetThumbTexture():SetHeight(32)
	VScroll:SetScript('OnValueChanged', function(_, value) ScrollFrame:SetVerticalScroll(value) end)

	local HScroll = CreateFrame('Slider', nil, OptionsFrame)
	HScroll:SetOrientation('HORIZONTAL')
	HScroll:SetPoint('BOTTOMLEFT', OptionsFrame, 'BOTTOMLEFT', 4, 4)
	HScroll:SetPoint('BOTTOMRIGHT', OptionsFrame, 'BOTTOMRIGHT', -20, 4)
	HScroll:SetMinMaxValues(0, 0)
	HScroll:SetValue(0)
	simpleAlts.StyleScrollBar(HScroll, 'HORIZONTAL')
	HScroll:SetScript('OnValueChanged', function(_, value) ScrollFrame:SetHorizontalScroll(value) end)

	local contentWidth, contentHeight = 0, 0

	-- Only runs when the window size or the content changes
	local function updateScroll()
		local maxX = math.max(0, contentWidth - ScrollFrame:GetWidth())
		local maxY = math.max(0, contentHeight - ScrollFrame:GetHeight())
		HScroll:SetMinMaxValues(0, maxX)
		VScroll:SetMinMaxValues(0, maxY)
		HScroll:SetShown(maxX > 0)
		VScroll:SetShown(maxY > 0)
	end
	ScrollFrame:EnableMouseWheel(true)
	ScrollFrame:SetScript('OnSizeChanged', updateScroll)
	ScrollFrame:SetScript('OnMouseWheel', function(_, delta)
		local Bar = IsShiftKeyDown() and HScroll or VScroll
		Bar:SetValue(Bar:GetValue() - delta * SCROLL_STEP)
	end)

	local LabelColumn = simpleAlts.LayoutLabelColumn(Content)

	function simpleAlts.LayoutCols()
		simpleAlts.ApplyRaidLayout()

		local sorted = {}
		for name, data in pairs(SimpleAltsDB.characters) do sorted[#sorted + 1] = {name = name, data = data} end
		table.sort(sorted, function(a, b) return a.data.index < b.data.index end)

		local FirstCol
		local PreviousCol = LabelColumn
		for _, entry in ipairs(sorted) do
			local Col = simpleAlts.GetCol(entry.name) or simpleAlts.AcquireCol(entry.name, entry.data)
			simpleAlts.PlaceColumn(Col, PreviousCol)
			FirstCol    = FirstCol or Col
			PreviousCol = Col
		end

		simpleAlts.LayoutTotalGold(Content, FirstCol)

		contentWidth, contentHeight = simpleAlts.GetLayoutSize(#sorted)
		Content:SetSize(contentWidth, contentHeight)
		updateScroll()
	end

	simpleAlts.LayoutCols()

	function simpleAlts.ToggleOptions()
		local isShown = OptionsFrame:IsShown()
		OptionsFrame:SetShown(not isShown)
	end

	simpleAlts.UnregisterEventHandler('ADDON_LOADED', buildOptionsFrame)
end

simpleAlts.RegisterEventHandler('ADDON_LOADED', buildOptionsFrame)