---@type string, simpleAlts
local _, simpleAlts = ...

---@param hex string
---@return Color
local function createColorTable(hex)
	local r, g, b = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return {r = tonumber(r, 16)/255, g = tonumber(g, 16)/255, b = tonumber(b, 16)/255, colorStr = '|cff' .. hex}
end

-- Simple way to modify GUI theme in 1 file just by
-- copy-pasting hex codes
simpleAlts.colors = {
	backgroundColor = createColorTable('060011'),
	borderColor		  = createColorTable('2A082E'),
	primaryColor    = createColorTable('831854'),
	secondaryColor  = createColorTable('10288C'),
	highlightColor  = createColorTable('FFADDC'),
}