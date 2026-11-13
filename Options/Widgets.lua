---@type string, simpleAlts
local _, simpleAlts = ...

local colors  = simpleAlts.colors

local SCROLL_THICKNESS    = 6
local SCROLL_LENGTH       = 32

---@param self Frame
---@param r number
---@param g number
---@param b number
---@param a number
local function setBackdropColor(self, r, g, b, a)
  self.BG:SetColorTexture(r, g, b, a)
end

---@param self Frame
---@param r number
---@param g number
---@param b number
---@param a number
local function setBackdropBorderColor(self, r, g, b, a)
  self.BorderTop:SetColorTexture(r, g, b, a)
  self.BorderBottom:SetColorTexture(r, g, b, a)
  self.BorderLeft:SetColorTexture(r, g, b, a)
  self.BorderRight:SetColorTexture(r, g, b, a)
end

---@param Frame Frame
---@param bgAlpha number?
---@param borderAlpha number?
function simpleAlts.CreateFlatBackdrop(Frame, bgAlpha, borderAlpha)
  Frame.BG = Frame:CreateTexture(nil, 'BACKGROUND')
  Frame.BG:SetPoint('TOPLEFT', 1, -1)
  Frame.BG:SetPoint('BOTTOMRIGHT', -1, 1)
  Frame.BG:SetColorTexture(colors.backgroundColor.r, colors.backgroundColor.g, colors.backgroundColor.b, bgAlpha or 0.4)

  Frame.BorderTop = Frame:CreateTexture(nil, 'BORDER')
  Frame.BorderTop:SetPoint('TOPLEFT', 0, 0)
  Frame.BorderTop:SetPoint('TOPRIGHT', 0, 0)
  Frame.BorderTop:SetHeight(1)
  Frame.BorderTop:SetColorTexture(colors.borderColor.r, colors.borderColor.g, colors.borderColor.b, borderAlpha or 1)

  Frame.BorderBottom = Frame:CreateTexture(nil, 'BORDER')
  Frame.BorderBottom:SetPoint('BOTTOMLEFT', 0, 0)
  Frame.BorderBottom:SetPoint('BOTTOMRIGHT', 0, 0)
  Frame.BorderBottom:SetHeight(1)
  Frame.BorderBottom:SetColorTexture(colors.borderColor.r, colors.borderColor.g, colors.borderColor.b, borderAlpha or 1)

  Frame.BorderLeft = Frame:CreateTexture(nil, 'BORDER')
  Frame.BorderLeft:SetPoint('TOPLEFT', 0, 0)
  Frame.BorderLeft:SetPoint('BOTTOMLEFT', 0, 0)
  Frame.BorderLeft:SetWidth(1)
  Frame.BorderLeft:SetColorTexture(colors.borderColor.r, colors.borderColor.g, colors.borderColor.b, borderAlpha or 1)

  Frame.BorderRight = Frame:CreateTexture(nil, 'BORDER')
  Frame.BorderRight:SetPoint('TOPRIGHT', 0, 0)
  Frame.BorderRight:SetPoint('BOTTOMRIGHT', 0, 0)
  Frame.BorderRight:SetWidth(1)
  Frame.BorderRight:SetColorTexture(colors.borderColor.r, colors.borderColor.g, colors.borderColor.b, borderAlpha or 1)

  Frame.SetBackdropColor       = setBackdropColor
  Frame.SetBackdropBorderColor = setBackdropBorderColor
end

---@param size number
---@param Parent Frame
---@param anchorPoint string
---@param AnchorFrame Frame
---@param relativePoint string
---@param xOffset number
---@param yOffset number
---@param tooltipText string?
---@param onClick fun()?
---@return Button
function simpleAlts.CreateXButton(size, Parent, anchorPoint, AnchorFrame, relativePoint, xOffset, yOffset, tooltipText, onClick)
	local Button = CreateFrame('Button', nil, Parent)
	Button:SetPoint(anchorPoint, AnchorFrame, relativePoint, xOffset, yOffset)
	Button:SetSize(size, size)
	Button:SetFrameStrata('DIALOG')

	Button.Texture = Button:CreateTexture(nil, 'ARTWORK')
	Button.Texture:SetAllPoints()
	Button.Texture:SetTexture('Interface\\AddOns\\SimpleAlts\\Media\\x.png')
	Button.Texture:SetVertexColor(1, 1, 1, 1)

	Button:SetScript('OnEnter', function(self)
		if self.isDown then return end
		self.Texture:SetVertexColor(colors.secondaryColor.r, colors.secondaryColor.g, colors.secondaryColor.b, 1)
		if tooltipText then
			GameTooltip:SetOwner(self, 'ANCHOR_TOP')
			---@diagnostic disable-next-line: missing-parameter
			GameTooltip:SetText(tooltipText)
			GameTooltip:Show()
		end
	end)
	Button:SetScript('OnLeave', function(self)
		if self.isDown then return end
		self.Texture:SetVertexColor(1, 1, 1, 1)
		if tooltipText then GameTooltip:Hide() end
	end)
	Button:SetScript('OnMouseDown', function(self)
		self.isDown = true
		self.Texture:SetVertexColor(colors.highlightColor.r, colors.highlightColor.g, colors.highlightColor.b, 1)
	end)
	Button:SetScript('OnMouseUp', function(self)
		self.isDown = false
		if self:IsMouseOver() then
			self.Texture:SetVertexColor(colors.secondaryColor.r, colors.secondaryColor.g, colors.secondaryColor.b, 1)
		else
			self.Texture:SetVertexColor(1, 1, 1, 1)
		end
	end)
	if onClick then Button:SetScript('OnClick', onClick) end

	return Button
end

---@param Parent Frame
---@return Button
function simpleAlts.CreateResizeButton(Parent)
	local Button = CreateFrame('Button', nil, Parent)
	Button:SetSize(16, 16)
	Button:SetPoint('BOTTOMRIGHT', Parent, 'BOTTOMRIGHT', 0, 0)
	Button:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up')
	Button:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down')
	Button:SetHighlightTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight')
	Button:SetFrameLevel(Parent:GetFrameLevel() + 50)

	return Button
end

---@param size number
---@param Parent Frame
---@param anchorPoint string
---@param AnchorFrame Frame
---@param relativePoint string
---@param xOffset number
---@param yOffset number
---@param rotation string
---@param tooltipText string
---@return Button
function simpleAlts.CreateArrowButton(size, Parent, anchorPoint, AnchorFrame, relativePoint, xOffset, yOffset, rotation, tooltipText)
	local Button = CreateFrame('Button', nil, Parent)
	Button:SetPoint(anchorPoint, AnchorFrame, relativePoint, xOffset, yOffset)
	Button:SetSize(size, size)

	Button.Texture = Button:CreateTexture(nil, 'ARTWORK')
	Button.Texture:SetAllPoints()
	Button.Texture:SetTexture('Interface\\AddOns\\SimpleAlts\\Media\\arrow.tga')
	Button.Texture:SetVertexColor(1, 1, 1, 1)
	if rotation == 'UP' then
		Button.Texture:SetRotation(math.rad(180))
	elseif rotation == 'LEFT' then
		Button.Texture:SetRotation(math.rad(-90))
	elseif rotation == 'RIGHT' then
		Button.Texture:SetRotation(math.rad(90))
	end

	Button:SetScript('OnEnter', function(self)
		self.Texture:SetVertexColor(colors.secondaryColor.r, colors.secondaryColor.g, colors.secondaryColor.b, 1)
		GameTooltip:SetOwner(self, 'ANCHOR_TOP')
		---@diagnostic disable-next-line: missing-parameter
		GameTooltip:SetText(tooltipText)
		GameTooltip:Show()
	end)
	Button:SetScript('OnLeave', function(self)
		self.Texture:SetVertexColor(1, 1, 1, 1)
		GameTooltip:Hide()
	end)
	Button:SetScript('OnMouseDown', function(self) self.Texture:SetVertexColor(colors.highlightColor.r, colors.highlightColor.g, colors.highlightColor.b, 1) end)
	Button:SetScript('OnMouseUp', function(self)
		if self:IsMouseOver() then
			self.Texture:SetVertexColor(colors.secondaryColor.r, colors.secondaryColor.g, colors.secondaryColor.b, 1)
		else
			self.Texture:SetVertexColor(1, 1, 1, 1)
		end
	end)

	return Button
end

---@param Parent Frame
---@param size number
---@param anchorPoint string
---@param AnchorFrame Frame|FontString
---@param relativePoint string
---@param xOffset number
---@param yOffset number
---@return Texture
function simpleAlts.CreateCheckTexture(Parent, size, anchorPoint, AnchorFrame, relativePoint, xOffset, yOffset)
	local Check = Parent:CreateTexture(nil, 'OVERLAY')
	Check:SetSize(size, size)
	Check:SetPoint(anchorPoint, AnchorFrame, relativePoint, xOffset, yOffset)
	Check:SetTexture('Interface\\AddOns\\SimpleAlts\\Media\\check.tga')
	Check:SetVertexColor(0, 1, 0, 1)
	Check:Hide()

	return Check
end

--- @param ScrollFrame Frame|Slider
--- @param orientation string?
--- @return Slider|Frame
function simpleAlts.StyleScrollBar(ScrollFrame, orientation)
  orientation = orientation or 'VERTICAL'

  local ScrollBar
  if ScrollFrame:GetObjectType() == 'Slider' then
    ScrollBar = ScrollFrame
  else
    local scrollBarName    = ScrollFrame:GetName() .. 'ScrollBar'
    ScrollBar              = _G[scrollBarName]
    local ScrollUpButton   = _G[scrollBarName .. 'ScrollUpButton']
    local ScrollDownButton = _G[scrollBarName .. 'ScrollDownButton']

    ScrollUpButton:Hide()
    ScrollUpButton:SetAlpha(0)
    ScrollUpButton:EnableMouse(false)
    ScrollDownButton:Hide()
    ScrollDownButton:SetAlpha(0)
    ScrollDownButton:EnableMouse(false)

    ScrollBar:ClearAllPoints()
    ScrollBar:SetPoint('TOPRIGHT', ScrollFrame, 'TOPRIGHT', 12, -2)
    ScrollBar:SetPoint('BOTTOMRIGHT', ScrollFrame, 'BOTTOMRIGHT', 12, 2)
  end

  local ScrollTrack = ScrollBar:CreateTexture(nil, 'BACKGROUND')
  ScrollTrack:SetAllPoints(ScrollBar)
  ScrollTrack:SetColorTexture(colors.borderColor.r, colors.borderColor.g, colors.borderColor.b, 0.5)

  local ThumbTexture = ScrollBar:GetThumbTexture()
	if not ThumbTexture then
		ThumbTexture = ScrollBar:CreateTexture(nil, 'OVERLAY')
		ScrollBar:SetThumbTexture(ThumbTexture)
	end
  ThumbTexture:SetColorTexture(colors.primaryColor.r, colors.primaryColor.g, colors.primaryColor.b, 1)

  if orientation == 'HORIZONTAL' then
    ScrollBar:SetHeight(SCROLL_THICKNESS)
    ThumbTexture:SetHeight(SCROLL_THICKNESS)
    ThumbTexture:SetWidth(SCROLL_LENGTH)
  else
    ScrollBar:SetWidth(SCROLL_THICKNESS)
    ThumbTexture:SetWidth(SCROLL_THICKNESS)
  end

  return ScrollBar
end