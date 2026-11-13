---@type string, simpleAlts
local _, simpleAlts = ...

local fonts = simpleAlts.fonts

local EQUIPMENT_ORDER = {1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17}

local HEADER_H      = 28
local CELL_H        = 20
local GEAR_CELL_H   = 24
local PADDING       = 4
local SEC_PAD       = 2
local SEC_GAP       = 2
local ILVL_ROW      = 1
local TOTAL_HEIGHT  = 24
local LABEL_WIDTH   = 80
local COL_WIDTH     = 200
local COL_GAP       = 2
local ICON_SIZE     = 16
local ICON_ZOOM     = 0.08
local BOX_SIZE      = 10
local BOX_GAP       = 2
local EMPTY_BOX     = {0.3, 0.3, 0.3}
local VAULT_SLOT_W  = 24
local VAULT_KEYS    = {'raid', 'dungeon', 'world'}
local DASH_COLOR    = {0.5, 0.5, 0.5}
local BLUE          = {0.00, 0.44, 0.87}
local PINK          = {1.00, 0.30, 1.00}
local ORANGE        = {1.00, 0.50, 0.00}
local RAID_TIERS    = {[14] = {'N', BLUE}, [15] = {'H', PINK}, [16] = {'M', ORANGE}}
local CELL_WIDTH    = COL_WIDTH - PADDING * 2
local TEXT_WIDTH    = CELL_WIDTH - ICON_SIZE - 4
local RAID_BLOCK    = CELL_H + BOX_SIZE + 1
local RAID_DIFFS    = {
	{ids = {15},      color = {1.00, 0.30, 1.00}},
	{ids = {16, 233}, color = {1.00, 0.50, 0.00}},
}

local SECTION_ORDER = {'Header', 'Gear', 'Vault', 'Raids', 'Gold'}
local FIXED_HEIGHTS = {
	Header = HEADER_H,
	Gear   = CELL_H + #EQUIPMENT_ORDER * GEAR_CELL_H + SEC_PAD * 2,
	Vault  = 3 * CELL_H + SEC_PAD * 2,
	Gold   = CELL_H + SEC_PAD * 2,
}

local SLOT_NAMES = {
	[1] = 'Head', [2] = 'Neck', [3] = 'Shoulder', [15] = 'Back', [5] = 'Chest', [9] = 'Wrist',
	[10] = 'Hands', [6] = 'Waist', [7] = 'Legs', [8] = 'Feet', [11] = 'Ring 1', [12] = 'Ring 2',
	[13] = 'Trinket 1', [14] = 'Trinket 2', [16] = 'Main Hand', [17] = 'Off Hand',
}
local TRACK_COLORS = {
	Explorer   = {0.62, 0.62, 0.62},
	Adventurer = {1.00, 1.00, 1.00},
	Veteran    = {0.12, 1.00, 0.00},
	Champion   = {0.00, 0.44, 0.87},
	Hero       = {1.00, 0.30, 1.00},
	Myth       = {1.00, 0.50, 0.00},
}
local DEFAULT_COLOR = TRACK_COLORS.Adventurer
local COIN_FORMAT   = '%d|TInterface\\MoneyFrame\\UI-GoldIcon:10:10:-2:0|t'
                    .. '%d|TInterface\\MoneyFrame\\UI-SilverIcon:10:10:-2:0|t'
                    .. '%d|TInterface\\MoneyFrame\\UI-CopperIcon:10:10:-2:0|t'

local cols      = {}
local ColMixin  = {}
local colHeight = 0
local LabelColumn, TotalGold

local Tooltip = CreateFrame('GameTooltip', 'SimpleAltsTooltip', UIParent, 'GameTooltipTemplate')
if Tooltip.NineSlice then Tooltip.NineSlice:SetBorderColor(0, 0, 0, 0) end

---@param copper number
---@return string
local function formatMoney(copper)
	return string.format(COIN_FORMAT, math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100)
end

-- Vertical center of a CELL_H line, relative to its section's top
---@param index number
---@return number
local function cellY(index)
	return -(SEC_PAD + (index - 1) * CELL_H + CELL_H / 2)
end

-- Vertical center of the i-th gear slot line, below the ILvl line
---@param i number
---@return number
local function gearY(i)
	return -(SEC_PAD + CELL_H + (i - 1) * GEAR_CELL_H + GEAR_CELL_H / 2)
end

-- Vertical center of a raid's heroic (d = 1) or mythic (d = 2) line, relative to the Raids section
---@param r number
---@param d number
---@return number
local function raidY(r, d)
	return -(SEC_PAD + (r - 1) * RAID_BLOCK + CELL_H / 2 + (d - 1) * (BOX_SIZE + 1))
end

---@param parent Frame
---@param font FontObject
---@param text string
---@param width number
---@param relativeTo Frame|FontString
---@param point string
---@param relativePoint string
---@param x number
---@param y number
---@return FontString
local function addLabel(parent, font, text, width, relativeTo, point, relativePoint, x, y)
	local label = parent:CreateFontString()
	label:SetFontObject(font)
	label:SetWidth(width)
	label:SetPoint(point, relativeTo, relativePoint, x, y)
	label:SetText(text)
	label:SetWordWrap(false)
	return label
end

---@param parent Frame
---@param text string
---@param index number
---@return FontString
local function addRowLabel(parent, text, index)
	local label = addLabel(parent, fonts.header, text, LABEL_WIDTH - PADDING, parent, 'LEFT', 'TOPLEFT', PADDING, cellY(index))
	label:SetJustifyH('LEFT')
	return label
end

---@param name string
---@return string
local function abbreviate(name)
	local result = ''
	for word in name:gmatch('%S+') do
		if word:lower() ~= 'the' then
			result = result .. word:sub(1, 1):upper()
		end
	end
	return result
end

---@param key string
---@return number
local function sectionHeight(key)
	if key == 'Raids' then
		return #(SimpleAltsDB.raidList or {}) * RAID_BLOCK + SEC_PAD * 2
	end
	return FIXED_HEIGHTS[key]
end

---@param parent Frame
---@param noBackdrop boolean?
local function createSections(parent, noBackdrop)
	parent.sections = {}
	local previous
	for _, key in ipairs(SECTION_ORDER) do
		local Section = CreateFrame('Frame', nil, parent)
		if not noBackdrop then simpleAlts.CreateFlatBackdrop(Section, 0.8, 1) end

		if previous then
			Section:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, -SEC_GAP)
			Section:SetPoint('TOPRIGHT', previous, 'BOTTOMRIGHT', 0, -SEC_GAP)
		else
			Section:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 0)
			Section:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 0, 0)
		end

		parent.sections[key] = Section
		previous = Section
	end
end

---@param parent Frame
---@return number
local function applyHeights(parent)
	local total = 0
	for i, key in ipairs(SECTION_ORDER) do
		local h = sectionHeight(key)
		parent.sections[key]:SetHeight(h)
		total = total + h + (i > 1 and SEC_GAP or 0)
	end
	parent:SetHeight(total)
	return total
end

---@param Col CharacterCol
local function deleteCol(_, Col)
	if Col.name then cols[Col.name] = nil end
	Col:Hide()
	Col:ClearAllPoints()
	Col.name = nil
	Col.data = nil
end

local ColPool = CreateFramePool('Frame', nil, nil, deleteCol)

---@param Col CharacterCol
local function refreshGold(Col)
	Col.Gold:SetText(formatMoney(Col.data.gold))
end

---@param Col CharacterCol
local function refreshGear(Col)
	local data  = Col.data
	local warn  = data.warn
	local track = data.track
	Col.ILvl:SetText(string.format('%.2f', data.ilvl))

	for slotId, Icon in pairs(Col.icons) do
		local link = data.equip[slotId]
		Icon.link = link
		if link then
			local itemName = link:match('%[(.-)%]') or ''
			local ilvl     = data.ilvls and data.ilvls[slotId]
			local name     = itemName:gsub('%s*|A.-|a', ''):gsub('%s*|T.-|t', '')
			Icon.Texture:SetTexture(select(5, C_Item.GetItemInfoInstant(link)))
			Icon.Name:SetText(ilvl and ilvl > 0 and (name .. ' (' .. ilvl .. ')') or name)

			local color = TRACK_COLORS[track and track[slotId]] or DEFAULT_COLOR
			Icon.Name:SetTextColor(color[1], color[2], color[3])
		else
			Icon.Texture:SetColorTexture(0, 0, 0, 0.3)
			Icon.Name:SetText('')
		end

		if warn and warn[slotId] then
			Icon:SetBackdropBorderColor(1, 0, 0, 1)
		else
			Icon:SetBackdropBorderColor(0.5255, 1, 0.4667, 1)
		end
	end
end

---@param key string
---@param level number|boolean
---@return string text
---@return number[] color
local function vaultSlot(key, level)
	if key == 'raid' then
		local tier = RAID_TIERS[level] or RAID_TIERS[14]
		return tier[1], tier[2]
	end

	if level <= 0 then return 'M', BLUE end
	return tostring(level), level >= 10 and ORANGE or PINK
end

---@param Col CharacterCol
local function refreshVault(Col)
	local vault = Col.data.vault

	for key, cells in pairs(Col.vaultCells) do
		local slots = type(vault[key]) == 'table' and vault[key] or {}

		for s, Text in ipairs(cells) do
			local level = slots[s]
			local done  = level ~= nil and level ~= false

			if key == 'world' then
				Text.Check:SetShown(done)
				Text:SetText(done and '' or '-')
				Text:SetTextColor(DASH_COLOR[1], DASH_COLOR[2], DASH_COLOR[3])
			elseif done then
				local label, c = vaultSlot(key, level)
				Text:SetText(label)
				Text:SetTextColor(c[1], c[2], c[3])
			else
				Text:SetText('-')
				Text:SetTextColor(DASH_COLOR[1], DASH_COLOR[2], DASH_COLOR[3])
			end
		end
	end
end

---@param byRaid table?
---@param ids number[]
---@param now number
---@return boolean[]?
local function getKills(byRaid, ids, now)
	if not byRaid then return nil end
	for _, id in ipairs(ids) do
		local entry = byRaid[id]
		if entry and entry.expires > now then return entry.kills end
	end
end

---@param Col CharacterCol
local function refreshRaids(Col)
	local raidList = SimpleAltsDB.raidList or {}
	local saved    = Col.data.raids
	local now      = GetServerTime()
	local Raids    = Col.sections.Raids

	Col.boxes = Col.boxes or {}
	for r, raid in ipairs(raidList) do
		Col.boxes[r] = Col.boxes[r] or {}
		local byRaid = saved and (saved[raid.name] or saved[raid.mapID])

		for d, diff in ipairs(RAID_DIFFS) do
			local boxes = Col.boxes[r][d] or {}
			Col.boxes[r][d] = boxes
			local kills = getKills(byRaid, diff.ids, now)

			for k = 1, raid.bosses do
				local Box = boxes[k]
				if not Box then
					Box = Raids:CreateTexture(nil, 'ARTWORK')
					Box:SetSize(BOX_SIZE, BOX_SIZE)
					Box:SetPoint('LEFT', Raids, 'TOPLEFT', PADDING + (k - 1) * (BOX_SIZE + BOX_GAP), raidY(r, d))
					boxes[k] = Box
				end

				local c = kills and kills[k] and diff.color or EMPTY_BOX
				Box:SetColorTexture(c[1], c[2], c[3], 1)
				Box:Show()
			end
			for k = raid.bosses + 1, #boxes do boxes[k]:Hide() end
		end
	end

	for r = #raidList + 1, #Col.boxes do
		for _, boxes in pairs(Col.boxes[r]) do
			for _, Box in ipairs(boxes) do Box:Hide() end
		end
	end
end

---@param Col CharacterCol
---@param offset number
local function moveCol(Col, offset)
	local data        = Col.data
	local targetIndex = data.index + offset

	for _, other in pairs(SimpleAltsDB.characters) do
		if other.index == targetIndex then
			other.index, data.index = data.index, other.index
			simpleAlts.LayoutCols()
			return
		end
	end
end

-- Arrows live in the Header section, so the column is two parents up
local function onMoveLeft(self)  moveCol(self:GetParent():GetParent(), -1) end
local function onMoveRight(self) moveCol(self:GetParent():GetParent(), 1) end

local function onIconEnter(self)
	if not self.link then return end
	Tooltip:SetOwner(self, 'ANCHOR_RIGHT')
	Tooltip:SetHyperlink(self.link)
	Tooltip:Show()
end

local function onIconLeave()
	Tooltip:Hide()
end

function ColMixin:Init()
	self:SetParent(simpleAlts.ColParent)
	self:SetWidth(COL_WIDTH)
	createSections(self)
	applyHeights(self)

	local Header, Gear, Vault, Gold = self.sections.Header, self.sections.Gear, self.sections.Vault, self.sections.Gold

	-- Header + arrows
	self.LeftArrow = simpleAlts.CreateArrowButton(ICON_SIZE, Header, 'TOPLEFT', Header, 'TOPLEFT', PADDING, -(HEADER_H - ICON_SIZE) / 2, 'LEFT', 'Move Left')
	self.LeftArrow:SetScript('OnClick', onMoveLeft)
	self.RightArrow = simpleAlts.CreateArrowButton(ICON_SIZE, Header, 'TOPRIGHT', Header, 'TOPRIGHT', -PADDING, -(HEADER_H - ICON_SIZE) / 2, 'RIGHT', 'Move Right')
	self.RightArrow:SetScript('OnClick', onMoveRight)
	self.Name = addLabel(Header, fonts.header, '', COL_WIDTH - (ICON_SIZE + PADDING * 2) * 2, Header, 'CENTER', 'TOP', 0, -HEADER_H / 2)

	-- Texts
	self.ILvl         = addLabel(Gear, fonts.body, '', CELL_WIDTH, Gear, 'LEFT', 'TOPLEFT', PADDING, cellY(ILVL_ROW))
	self.Gold         = addLabel(Gold, fonts.body, '', CELL_WIDTH, Gold, 'LEFT', 'TOPLEFT', PADDING, cellY(1))
	self.vaultCells = {}
	for line, key in ipairs(VAULT_KEYS) do
		local cells = {}
		for s = 1, 3 do
			local Text = addLabel(Vault, fonts.body, '', VAULT_SLOT_W, Vault, 'LEFT', 'TOPLEFT', PADDING + (s - 1) * VAULT_SLOT_W, cellY(line))
			Text:SetJustifyH('CENTER')
			if key == 'world' then
				Text.Check = simpleAlts.CreateCheckTexture(Vault, 12, 'CENTER', Text, 'CENTER', 0, 0)
			end
			cells[s] = Text
		end
		self.vaultCells[key] = cells
	end

	-- Equipment
	self.icons = {}
	for i, slotId in ipairs(EQUIPMENT_ORDER) do
		local Icon = CreateFrame('Button', nil, Gear)
		Icon:SetSize(ICON_SIZE, ICON_SIZE)
		Icon:SetPoint('LEFT', Gear, 'TOPLEFT', PADDING, gearY(i))

		Icon.Texture = Icon:CreateTexture(nil, 'ARTWORK')
		Icon.Texture:SetTexCoord(ICON_ZOOM, 1 - ICON_ZOOM, ICON_ZOOM, 1 - ICON_ZOOM)
		Icon.Texture:SetPoint('TOPLEFT', 1, -1)
		Icon.Texture:SetPoint('BOTTOMRIGHT', -1, 1)
		simpleAlts.CreateFlatBackdrop(Icon, 0, 0)

		Icon.Name = addLabel(Icon, fonts.body, '', TEXT_WIDTH, Icon, 'LEFT', 'RIGHT', 4, 0)
		Icon.Name:SetJustifyH('LEFT')
		Icon.Name:SetWordWrap(true)
		Icon.Name:SetMaxLines(2)
		Icon.Name:SetHeight(GEAR_CELL_H)
		Icon:SetHitRectInsets(0, -(TEXT_WIDTH + 4), 0, 0)

		Icon:SetScript('OnEnter', onIconEnter)
		Icon:SetScript('OnLeave', onIconLeave)

		self.icons[slotId] = Icon
	end

	self.initialized = true
end

---@param name string
---@param data CharacterData
---@return CharacterCol
function simpleAlts.AcquireCol(name, data)
	local Col = ColPool:Acquire()

	if not Col.initialized then
		Mixin(Col, ColMixin)
		Col:Init()
	end

	Col.name = name
	Col.data = data
	cols[name] = Col

	Col.Name:SetText(data.name or name)
	refreshGold(Col)
	refreshGear(Col)
	refreshVault(Col)
	refreshRaids(Col)

	return Col
end

---@param name string
---@return CharacterCol?
function simpleAlts.GetCol(name)
	return cols[name]
end

---@param Col Frame
---@param previous Frame
function simpleAlts.PlaceColumn(Col, previous)
	Col:ClearAllPoints()
	Col:SetPoint('TOPLEFT', previous, 'TOPRIGHT', COL_GAP, 0)
	Col:Show()
end

---@param numCols number
---@return number width
---@return number height
function simpleAlts.GetLayoutSize(numCols)
	return LABEL_WIDTH + numCols * (COL_WIDTH + COL_GAP), colHeight + TOTAL_HEIGHT
end

---@param parent Frame
---@return Frame
function simpleAlts.LayoutLabelColumn(parent)
	if LabelColumn then return LabelColumn end

	LabelColumn = CreateFrame('Frame', nil, parent)
	LabelColumn:SetWidth(LABEL_WIDTH)
	LabelColumn:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 0)
	createSections(LabelColumn, true)
	colHeight = applyHeights(LabelColumn)

	local Gear, Vault, Gold = LabelColumn.sections.Gear, LabelColumn.sections.Vault, LabelColumn.sections.Gold

	addRowLabel(Gear, 'ILvl', ILVL_ROW)
	for i, slotId in ipairs(EQUIPMENT_ORDER) do
		local label = addLabel(Gear, fonts.header, SLOT_NAMES[slotId], LABEL_WIDTH - PADDING, Gear, 'LEFT', 'TOPLEFT', PADDING, gearY(i))
		label:SetJustifyH('LEFT')
	end
	addRowLabel(Vault, 'Raid', 1)
	addRowLabel(Vault, 'Dungeons', 2)
	addRowLabel(Vault, 'World', 3)
	addRowLabel(Gold, 'Gold', 1)

	return LabelColumn
end

local function updateTotal()
	if not TotalGold then return end

	local total = 0
	for _, data in pairs(SimpleAltsDB.characters) do total = total + data.gold end
	TotalGold:SetText(formatMoney(total))
end

---@param parent Frame
---@param lastCol Frame
function simpleAlts.LayoutTotalGold(parent, lastCol)
	if not TotalGold then
		TotalGold = parent:CreateFontString()
		TotalGold:SetFontObject(fonts.body)
		TotalGold:SetWidth(CELL_WIDTH)
		TotalGold:SetJustifyH('RIGHT')
	end

	updateTotal()

	TotalGold:ClearAllPoints()
	TotalGold:SetPoint('TOPRIGHT', lastCol, 'BOTTOMRIGHT', -PADDING - 2.5, -4)
end

---@param name string
---@param field 'gold'|'gear'|'vault'|'raids'
function simpleAlts.RefreshCol(name, field)
	local Col = cols[name]
	if not Col or not Col:IsVisible() then return end

	if field == 'gold' then
		refreshGold(Col)
		updateTotal()
	elseif field == 'gear' then
		refreshGear(Col)
	elseif field == 'vault' then
		refreshVault(Col)
	elseif field == 'raids' then
		refreshRaids(Col)
	end
end

function simpleAlts.RefreshAll()
	for _, Col in pairs(cols) do
		refreshGold(Col)
		refreshGear(Col)
		refreshVault(Col)
		refreshRaids(Col)
	end
	updateTotal()
end

function simpleAlts.ApplyRaidLayout()
	local raidList = SimpleAltsDB.raidList or {}

	if LabelColumn then
		colHeight = applyHeights(LabelColumn)

		local Raids  = LabelColumn.sections.Raids
		local labels = LabelColumn.raidLabels or {}
		LabelColumn.raidLabels = labels

		for r, raid in ipairs(raidList) do
			local label = labels[r]
			if not label then
				label = addLabel(Raids, fonts.header, '', LABEL_WIDTH - PADDING, Raids, 'LEFT', 'TOPLEFT', PADDING, raidY(r, 1))
				label:SetJustifyH('LEFT')
				labels[r] = label
			end
			label:SetText(abbreviate(raid.name))
			label:Show()
		end
		for r = #raidList + 1, #labels do labels[r]:Hide() end
	end

	for _, Col in pairs(cols) do
		applyHeights(Col)
		refreshRaids(Col)
	end
end