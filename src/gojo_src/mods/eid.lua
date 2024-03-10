local EID_LOCAL = {}

if not EID then
	EID_LOCAL.UpdateEID = function() end
	EID_LOCAL.postRender = function() end
	EID_LOCAL.postNewRoom = function() end

	return EID_LOCAL
end




local enums = require("gojo_src.core.enums")

--set icons
local icons = Sprite()
icons:Load("gfx/eid_gojo_icons.anm2", true)
EID:addIcon("Player" .. enums.PLAYERS.GOJO.ID, "Players", 0, 32, 32, 0, 0, icons)

local GojoIcon = "{{Player" .. enums.PLAYERS.GOJO.ID .. "}}"

local Descriptions = {
	[enums.ITEMS.INFINITE_VOID.ID] = "↑ {{Damage}} +0.5 Damage#{{Blank}} {{Damage}} Bonus +0.2 per use#↑ {{Speed}} +0.15 Speed#↑ {{Shotspeed}} +0.2 Shot speed#{{Timer}} Vulnerable non-boss enemies will petrify for a while for the current room and the next 2 rooms#{{Blank}} \7 Also petrifies bosses after 5 usages",
	[enums.ITEMS.LIMIT.ID] = "Enemy projectiles won't be able reach you",
	[enums.ITEMS.INVERTED_SPEAR_OF_HEAVEN.ID] = "↑ {{Damage}} +2.5 Damage#{{Coin}} +1 coin on pickup#{{SoulHeart}} +1 Soul Heart",
	[enums.ITEMS.SUKUNA_FINGER.ID] = "Placeholder" --fix later
}

local Birthrights = {
	[enums.PLAYERS.GOJO.Name] = "Cursed hearts no longer hurt you#Turns all red heart pickups to cursed hearts#{{TreasureRoomChanceSmall}} {{ColorSilver}}Throughout heaven and earth, I alone am the {{ColorRainbow}}Honored One{{ColorSilver}}."
}

function EID_LOCAL:UpdateEID()
	for k, v in pairs(Descriptions) do
		EID:addCollectible(k, v)
	end

	for _, char in pairs(enums.PLAYERS) do
		local desc = Birthrights[char.Name]
		if not desc then goto continue end

		EID:addBirthright(char.ID, desc, char.Name)

		::continue::
	end

end

function EID_LOCAL.postRender()
	local player = Isaac.GetPlayer()
	if player and player:GetPlayerType() == enums.PLAYERS.GOJO.ID then
		EID:addTextPosModifier("gojo", Vector(20, 0))
	else
		EID:removeTextPosModifier("gojo")
	end
end

function EID_LOCAL.postNewRoom()
	EID_LOCAL:UpdateEID()
end

return EID_LOCAL