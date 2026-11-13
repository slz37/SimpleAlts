---@type string, simpleAlts
local _, simpleAlts = ...

local fonts = simpleAlts.fonts

local COL_SPACING     = 4
local EQUIPMENT_ORDER = {1, 2, 3, 15, 5, 9, 16, 17, 10, 6, 7, 8, 11, 12, 13, 14}
local COIN_FORMAT     = '%d|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:2:0|t'
                      .. '%d|TInterface\\MoneyFrame\\UI-SilverIcon:14:14:2:0|t'
                      .. '%d|TInterface\\MoneyFrame\\UI-CopperIcon:14:14:2:0|t'

local RowMixin = {}

---@param Row CharacterRow
local function deleteRow(_, Row)
	Row:Hide()
	Row:ClearAllPoints()
	Row.name = nil
	Row.data = nil
end

---@param name string
function RowMixin:Init(name)
  self:SetParent(simpleAlts.OptionsFrame)
	simpleAlts.CreateFlatBackdrop(self, 0.8, 1)
  self:SetHeight(24)

  -- Texts
  self.Name = self:CreateFontString()
  self.Name:SetPoint('LEFT', self, 'LEFT', COL_SPACING, 0)
  self.Name:SetFontObject(fonts.body)
  self.ILvl = self:CreateFontString()
  self.ILvl:SetPoint('LEFT', self.Name, 'RIGHT', COL_SPACING, 0)
  self.ILvl:SetFontObject(fonts.body)
  self.Gold = self:CreateFontString()
  self.Gold:SetPoint('LEFT', self.ILvl, 'RIGHT', COL_SPACING, 0)
  self.Gold:SetFontObject(fonts.body)
  self.VaultRaid = self:CreateFontString()
  self.VaultRaid:SetPoint('LEFT', self.Gold, 'RIGHT', COL_SPACING, 0)
  self.VaultRaid:SetFontObject(fonts.body)
  self.VaultDungeon = self:CreateFontString()
  self.VaultDungeon:SetPoint('LEFT', self.VaultRaid, 'RIGHT', COL_SPACING, 0)
  self.VaultDungeon:SetFontObject(fonts.body)
  self.VaultWorld = self:CreateFontString()
  self.VaultWorld:SetPoint('LEFT', self.VaultDungeon, 'RIGHT', COL_SPACING, 0)
  self.VaultWorld:SetFontObject(fonts.body)

  local function onIconEnter()
    if not self.link then return end
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetHyperlink(self.link)
    GameTooltip:Show()
  end

  local function onIconLeave()
    GameTooltip:Hide()
  end

  -- Equipment textures
  self.icons = {}
  local PreviousIcon = self.VaultWorld
  for _, slotId in ipairs(EQUIPMENT_ORDER) do
    local Icon = CreateFrame('Button', nil, self)
    Icon:SetSize(16, 16)
    Icon:SetPoint('LEFT', PreviousIcon, 'RIGHT', COL_SPACING, 0)

    Icon.Texture = Icon:CreateTexture(nil, 'ARTWORK')
    Icon.Texture:SetAllPoints()

    Icon:SetScript('OnEnter', onIconEnter)
		Icon:SetScript('OnLeave', onIconLeave)

    self.icons[slotId] = Icon
    PreviousIcon = Icon
  end

	-- Options Buttons
	self.UpArrow   = simpleAlts.CreateArrowButton(16, self, 'LEFT', self.icons[#EQUIPMENT_ORDER], 'RIGHT', -COL_SPACING, 0, true, 'Move Up')
	self.DownArrow = simpleAlts.CreateArrowButton(16, self, 'LEFT', self.UpArrow, 'RIGHT', -COL_SPACING, 0, false, 'Move Down')
	self.Delete    = simpleAlts.CreateXButton(16, self, 'LEFT', self.DownArrow, 'RIGHT', -COL_SPACING, 0, 'Delete Character', function() simpleAlts.DeleteRow(name) end)

  self.initialized = true
end

local RowPool = CreateFramePool('Frame', nil, 'BackdropTemplate', deleteRow)

---@param copper number
---@return string
local function formatMoney(copper)
	return string.format(COIN_FORMAT, math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100)
end

---@param name string
---@param data table<string, any>
---@return CharacterRow
function simpleAlts.AcquireRow(name, data)
	local Row = RowPool:Acquire()

  if not Row.initialized then
    Mixin(Row, RowMixin)
    Row:Init(name, data)
  end

  Row.Name:SetText(data.name)
  Row.Gold:SetText(formatMoney(data.gold))
  Row.ILvl:SetText(string.format('%.2f', data.ilvl))
  Row.VaultRaid:SetText(data.vault.raid .. '/3')
  Row.VaultDungeon:SetText(data.vault.dungeon .. '/3')
  Row.VaultWorld:SetText(data.vault.world .. '/3')

  for slotId, Icon in pairs(Row.icons) do
		local link = data.equip[slotId]
		Icon.link = link
		if link then
			Icon.Texture:SetTexture(select(5, C_Item.GetItemInfoInstant(link)))
		else
			Icon.Texture:SetColorTexture(0, 0, 0, 0.3)
		end
	end

	Row.name = name
	Row.data = data

  return Row
end

function simpleAlts.DeleteRow(name)
end