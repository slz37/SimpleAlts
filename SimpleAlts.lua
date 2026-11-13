---@type string, simpleAlts
local ADDON_NAME, simpleAlts = ...

local LSM  = LibStub('LibSharedMedia-3.0')
local font = LSM:Fetch('font', 'PT Sans Narrow Bold', true)
if not font then
	local fontPath = 'Interface\\Addons\\SimpleAlts\\Media\\PTSansNarrow-Bold.ttf'
	LSM:Register('font', 'PT Sans Narrow Bold', fontPath)
	font = fontPath
end

simpleAlts.defaultFont    = font
simpleAlts.defaultTexture = LSM:Fetch('statusbar', 'Solid')

-- Slash command
SLASH_AN1 = '/sa'
SlashCmdList['SA'] = function() simpleAlts:ToggleOptions() end

-- Minimap icon
local LDB            = LibStub('LibDataBroker-1.1')
local LDBIcon        = LibStub('LibDBIcon-1.0')
local simpleAltsBroker = LDB:NewDataObject('Simple Alts', {
  type    = 'launcher',
  text    = 'Simple Alts',
  icon    = 'Interface\\Icons\\Inv_pet_cats_whitekitten',
  OnClick = function() simpleAlts:ToggleOptions() end,
})

function simpleAlts.ToggleMinimapButton()
  if SimpleAltsDB.minimap.isVisible then
    LDBIcon:Show('Simple Alts')
  else
    LDBIcon:Hide('Simple Alts')
  end
end

---@type EventFrame
local EventFrame    = CreateFrame('Frame', nil, UIParent)
EventFrame.handlers = {}

simpleAlts.unitEventData = simpleAlts.unitEventData or {}
simpleAlts.unitFramePool = simpleAlts.unitFramePool or {}

---@param self EventFrame
---@param event string
---@vararg ...
EventFrame:SetScript('OnEvent', function(self, event, ...)
	local handler = self.handlers[event]
	if not handler then return end

	local snapshot = {}
	for i, func in ipairs(handler.list) do snapshot[i] = func end

	-- Iterate over a snapshot of the callbacks to avoid deregistration conflicts
	for _, func in ipairs(snapshot) do
		if handler.lookup[func] then func(event, ...) end
	end
end)

---@param event string
---@param func fun()
function simpleAlts.RegisterEventHandler(event, func)
	local handler = EventFrame.handlers[event]
	if not handler then
		handler = {list = {}, lookup = {}}
		EventFrame.handlers[event] = handler
		EventFrame:RegisterEvent(event)
	end

	if handler.lookup[func] then return end

	handler.lookup[func] = true
	handler.list[#handler.list + 1] = func
end

---@param event string
---@param func fun()
function simpleAlts.UnregisterEventHandler(event, func)
	local handler = EventFrame.handlers[event]
	if not handler then return end
	if not handler.lookup[func] then return end

	handler.lookup[func] = nil
	for i = #handler.list, 1, -1 do
		if handler.list[i] == func then
			table.remove(handler.list, i)
			break
		end
	end

	if #handler.list == 0 then
		EventFrame:UnregisterEvent(event)
		EventFrame.handlers[event] = nil
	end
end

---@param addonName string
local function init(_, addonName)
	if addonName ~= ADDON_NAME then return end

	-- DB initialization/syncing
	SimpleAltsDB = SimpleAltsDB or {}
	simpleAlts.EnsureDB()

	-- Minimap icon initialization
	LDBIcon:Register('Simple Alts', simpleAltsBroker, SimpleAltsDB.minimap)
	simpleAlts.UnregisterEventHandler('ADDON_LOADED', init)
end

simpleAlts.RegisterEventHandler('ADDON_LOADED', init)