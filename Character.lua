---@type string, simpleAlts
local _, simpleAlts = ...

local VAULT_TYPES = {
  raid    = Enum.WeeklyRewardChestThresholdType.Raid,
  dungeon = Enum.WeeklyRewardChestThresholdType.Activities,
  world   = Enum.WeeklyRewardChestThresholdType.World,
}

local data

local function updateGold()
  data.gold = GetMoney()
end

local function updateGear()
  if not data then return end

  data.ilvl = select(2, GetAverageItemLevel())
  for slotId = 1, 17 do
    data.equip[slotId] = GetInventoryItemLink('player', slotId)
  end
end

local function updateVault()
  if not data then return end

  local vault = data.vault
  for key, activityType in pairs(VAULT_TYPES) do
    local unlocked = 0
    for _, activity in ipairs(C_WeeklyRewards.GetActivities(activityType)) do
      if activity.progress >= activity.threshold then
        unlocked = unlocked + 1
      end
    end
    vault[key] = unlocked
  end
end

---@param isLogin boolean
---@param isReload boolean
local function initCharacter(_, isLogin, isReload)
  if not isLogin and not isReload then return end

  local name, realm = UnitFullName('player')
  local fullName = name .. ' - ' .. realm

  local _, class    = UnitClass('player')
  local classColor  = C_ClassColor.GetClassColor(class)
  local coloredName = C_ColorUtil.WrapTextInColor(fullName, classColor)

  if not SimpleAltsDB.characters[fullName] then
    SimpleAltsDB.numChars = SimpleAltsDB.numChars + 1
    SimpleAltsDB.characters[fullName] = {
      name  = coloredName,
      index = SimpleAltsDB.numChars,
      ilvl  = 0,
      gold  = 0,
      equip = {},
      vault = {},
    }
  end

  data = SimpleAltsDB.characters[fullName]

  updateGold()
  updateGear()
  updateVault()

  simpleAlts.UnregisterEventHandler('PLAYER_ENTERING_WORLD', initCharacter)
end

simpleAlts.RegisterEventHandler('PLAYER_ENTERING_WORLD', initCharacter)
simpleAlts.RegisterEventHandler('PLAYER_MONEY', updateGold)
simpleAlts.RegisterEventHandler('PLAYER_EQUIPMENT_CHANGED', updateGear)
simpleAlts.RegisterEventHandler('UNIT_INVENTORY_CHANGED', updateGear)
simpleAlts.RegisterEventHandler('WEEKLY_REWARDS_UPDATE', updateVault)