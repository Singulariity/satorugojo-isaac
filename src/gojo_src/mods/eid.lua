local EID_LOCAL = {}

if not EID then
	EID_LOCAL.UpdateEID = function() end

	return EID_LOCAL
end




local Utils = require("gojo_src.utils")
local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")

--TODO
local function setIcons()
	local icons = Sprite()
	icons:Load("gfx/coop menu.anm2", true)
	EID:addIcon("Player" .. enums.PLAYERS.GOJO, "Gojo", 0, 16, 16, 0, 0, icons)
end
setIcons()

function EID_LOCAL:UpdateEID()
	local transform_count = Utils:tableLength(save.Data.TransformationPickIDs)
	local transform_str = "{{Blank}} {{ColorTransform}} Sorcerer (" .. math.min(transform_count, 3) .. "/3)#"

	EID:addCollectible(enums.ITEMS.INFINITE_VOID, transform_str .. "↑ {{Damage}} +0.5 Damage#{{Blank}} {{Damage}} Bonus +0.2 per use (up to 10 times)#↑ {{Speed}} +0.15 Speed#↑ {{Shotspeed}} +0.2 Shot speed#When activated:#{{Blank}} {{Timer}} Vulnerable non-boss enemies will petrify for a moment when you enter a room for the next 2 rooms#{{Blank}} \7 Also petrifies bosses after 5 usages")
	EID:addBirthright(enums.PLAYERS.GOJO, "{{TreasureRoomChanceSmall}} {{ColorSilver}}Throughout heaven and earth, I alone am the {{ColorRainbow}}Honored One{{ColorSilver}}.")
end

return EID_LOCAL