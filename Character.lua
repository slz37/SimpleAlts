---@type string, simpleAlts
local _, simpleAlts = ...

local VAULT_TYPES = {
  raid    = Enum.WeeklyRewardChestThresholdType.Raid,
  dungeon = Enum.WeeklyRewardChestThresholdType.Activities,
  world   = Enum.WeeklyRewardChestThresholdType.World,
}
local ENCHANTABLE       = {[1] = true, [3] = true, [5] = true, [7] = true, [8] = true, [11] = true, [12] = true, [16] = true}
local CRAFTED_TRACK     = {[13835] = 'Hero', [13836] = 'Myth'}
local RAID_DIFFICULTIES = {15, 16, 233}

local data, fullName

---@param slotId number
---@param link string?
---@return boolean, string?
local function scanItem(slotId, link)
  if not link then return false, nil end

  local warn, track = false, nil
  local _, enchantId, gem1, gem2, gem3, gem4 = link:match('item:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*)')

  -- Check for missing enchants
  if ENCHANTABLE[slotId] and (not enchantId or enchantId == '') then warn = true end

  -- Color for crafted items
  for bonusId, name in pairs(CRAFTED_TRACK) do
    if link:find(':' .. bonusId .. '[:|]') then track = name end
  end

  -- Color for upgrade tracks and check for missing upgrades
  local upgrade = C_Item.GetItemUpgradeInfo(link)
  if upgrade and upgrade.trackString and upgrade.maxLevel then
    track = upgrade.trackString
    if (upgrade.currentLevel or 0) < upgrade.maxLevel then warn = true end
  end

  local tip = C_TooltipInfo.GetInventoryItem('player', slotId)
  if not tip then return warn, track end

  -- Check for missing gems
  local sockets = 0
    for _, line in ipairs(tip.lines) do
    if line.type == Enum.TooltipDataLineType.GemSocket then
      sockets = sockets + 1
    end
  end

  if sockets > 0 then
    local filled = 0
    for _, gem in ipairs({gem1, gem2, gem3, gem4}) do
      if gem and gem ~= '' then filled = filled + 1 end
    end
    if filled < sockets then warn = true end
  end

  return warn, track
end

local function updateGold()
  if not data then return end

  data.gold = GetMoney()
  simpleAlts.RefreshCol(fullName, 'gold')
end

local function updateGear()
  if not data then return end

  data.warn  = data.warn or {}
  data.track = data.track or {}
  data.ilvls = data.ilvls or {}
  data.ilvl  = select(2, GetAverageItemLevel())

  for slotId = 1, 17 do
    local link = GetInventoryItemLink('player', slotId)
    local warn, track = scanItem(slotId, link)

    data.equip[slotId] = link
    data.warn[slotId]  = warn
    data.track[slotId] = track
    data.ilvls[slotId] = link and (C_Item.GetDetailedItemLevelInfo(link))
  end

  simpleAlts.RefreshCol(fullName, 'gear')
end

local function updateVault()
  if not data then return end

  local vault = data.vault
  for key, activityType in pairs(VAULT_TYPES) do
    local slots = {false, false, false}
    for _, activity in ipairs(C_WeeklyRewards.GetActivities(activityType)) do
      if activity.progress >= activity.threshold then
        slots[activity.index] = key == 'world' or activity.level or 0
      end
    end
    vault[key] = slots
  end
  simpleAlts.RefreshCol(fullName, 'vault')
end

local function updateRaids()
  if not data then return end

  local raids = {}
  for i = 1, GetNumSavedInstances() do
    local name, _, reset, difficulty, locked, _,_, isRaid, _,_, numEncounters, _,_, instanceId = GetSavedInstanceInfo(i)
    if isRaid and locked and tContains(RAID_DIFFICULTIES, difficulty) then
      local kills = {}
      for j = 1, numEncounters do
        local _,_, isKilled = GetSavedInstanceEncounterInfo(i, j)
        kills[j] = isKilled
      end

      local byRaid = raids[name] or {}
      byRaid[difficulty] = {kills = kills, expires = GetServerTime() + reset}
      raids[name] = byRaid
      if instanceId then raids[instanceId] = byRaid end
    end
  end

  data.raids = raids
  simpleAlts.RefreshCol(fullName, 'raids')
end

local function updateRaidList()
  EJ_SelectTier(EJ_GetNumTiers())

  local list  = {}
  local index = 2 -- World bosses are index 1
  while true do
    local id, name = EJ_GetInstanceByIndex(index, true)
    if not id then break end

    EJ_SelectInstance(id)
    local mapID = select(10, EJ_GetInstanceInfo(id))
    local bosses = 0
    while EJ_GetEncounterInfoByIndex(bosses + 1) do bosses = bosses + 1 end

    list[#list + 1] = {name = name, bosses = bosses, mapID = mapID}
    index = index + 1
  end

  if #list > 0 then
    SimpleAltsDB.raidList = list
    simpleAlts.LayoutCols()
  end
end

---@param isLogin boolean
---@param isReload boolean
local function initCharacter(_, isLogin, isReload)
  if not isLogin and not isReload then return end

  local name, realm = UnitFullName('player')
  fullName = name .. ' - ' .. realm

  local _, class    = UnitClass('player')
  local classColor  = C_ClassColor.GetClassColor(class)
  local coloredName = C_ColorUtil.WrapTextInColor(fullName, classColor)

  local isNew = not SimpleAltsDB.characters[fullName]
  if isNew then
    SimpleAltsDB.numChars = SimpleAltsDB.numChars + 1
    SimpleAltsDB.characters[fullName] = {
      name  = coloredName,
      index = SimpleAltsDB.numChars,
      ilvl  = 0,
      gold  = 0,
      equip = {},
      vault = {},
      warn  = {},
      ilvls = {},
    }
  end

  data = SimpleAltsDB.characters[fullName]

  updateGold()
  updateGear()
  updateVault()
  RequestRaidInfo()
  C_Timer.After(3, updateRaidList)

  if isNew then simpleAlts.LayoutCols() end

  simpleAlts.UnregisterEventHandler('PLAYER_ENTERING_WORLD', initCharacter)
end

---@param success number
local function onEncounterEnd(_,_,_,_,_, success)
  if success == 1 then RequestRaidInfo() end
end

simpleAlts.RegisterEventHandler('PLAYER_ENTERING_WORLD', initCharacter)
simpleAlts.RegisterEventHandler('PLAYER_MONEY', updateGold)
simpleAlts.RegisterEventHandler('PLAYER_EQUIPMENT_CHANGED', updateGear)
simpleAlts.RegisterEventHandler('UNIT_INVENTORY_CHANGED', updateGear)
simpleAlts.RegisterEventHandler('PLAYER_AVG_ITEM_LEVEL_UPDATE', updateGear)
simpleAlts.RegisterEventHandler('WEEKLY_REWARDS_UPDATE', updateVault)
simpleAlts.RegisterEventHandler('ENCOUNTER_END', onEncounterEnd)
simpleAlts.RegisterEventHandler('UPDATE_INSTANCE_INFO', updateRaids)