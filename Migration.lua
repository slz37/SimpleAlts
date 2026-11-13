---@type string, simpleAlts
local ADDON_NAME, simpleAlts = ...

local currentVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, 'Version')

local DB_DEFAULTS = {
  version      = currentVersion,
  numChars     = 0,
  characters   = {},
  blacklist    = {},
  OptionsFrame = {},
  minimap      = {isVisible = true},
}

 --[[
  enabled            = true,
  version            = currentVersion,
  guildMajority      = true,
  pushUninstanced    = false,
  useFakeRoster      = false,
  noteFormat         = 'always',
  forceNote          = false,
  minimap            = {isVisible = true},
  forceNoteName      = '',
  notes              = {},
  inactiveNotes      = {},
  blacklist          = {},
  OptionsFrame       = {},
  HelpFrame          = {},
  fakeRosters        = {},
  bossOrder          = {},
  selectedFakeRoster = 'Default',
  ]]

local function initiateMissingValues()
  for key, value in pairs(DB_DEFAULTS) do
    if SimpleAltsDB[key] == nil then SimpleAltsDB[key] = value end
  end
end

---@param version string
---@param threshold string
---@return boolean
local function versionNeedsUpdate(version, threshold)
  if not version then return true end -- Version was not tracked in DB before v2.0.0

  local versionMajor, versionMinor, versionPatch       = version:match('v(%d+)%.(%d+)%.(%d+)')
  local thresholdMajor, thresholdMinor, thresholdPatch = threshold:match('v(%d+)%.(%d+)%.(%d+)')

  versionMajor, versionMinor, versionPatch       = tonumber(versionMajor), tonumber(versionMinor), tonumber(versionPatch)
  thresholdMajor, thresholdMinor, thresholdPatch = tonumber(thresholdMajor), tonumber(thresholdMinor), tonumber(thresholdPatch)

  return versionMajor < thresholdMajor or
        (versionMajor == thresholdMajor and (versionMinor < thresholdMinor or
        (versionMinor == thresholdMinor and versionPatch < thresholdPatch)))
end

function simpleAlts.EnsureDB()
  local version = SimpleAltsDB['version']

  initiateMissingValues()

  --[[if versionNeedsUpdate(version, 'v2.0.0') then
  end]]

  -- Migration complete, bump DB version
  SimpleAltsDB['version'] = currentVersion
end