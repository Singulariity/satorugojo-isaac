local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")
local Utils = require("gojo_src.utils")

local Manager = {}

---@param entity Entity
function Manager.postEntityKill(entity)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() ~= enums.PLAYERS.GOJO then return end

	local type = entity.Type

	if type == EntityType.ENTITY_MOMS_HEART and not save.Data.PermanentData.Unlocks.Limit then
		save.Data.PermanentData.Unlocks.Limit = true
		Utils:ShowAchievement("achievement_limit.png")
	end

	if type == EntityType.ENTITY_DELIRIUM and not save.Data.PermanentData.Unlocks.InfiniteVoid then
		save.Data.PermanentData.Unlocks.InfiniteVoid = true
		Utils:ShowAchievement("achievement_infinite_void.png")
	end

end

---@param pickup EntityPickup
function Manager.postPickupInit(pickup)
	if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end

	local bools = (pickup.SubType == enums.ITEMS.INFINITE_VOID and not save.Data.PermanentData.Unlocks.InfiniteVoid) or
	(pickup.SubType == enums.ITEMS.LIMIT and not save.Data.PermanentData.Unlocks.Limit)

	if bools then
		local pool = Game():GetItemPool():GetPoolForRoom(Game():GetRoom():GetType(), Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)
		local target = Game():GetItemPool():GetCollectible(pool, true, pickup.InitSeed)
		Game():GetItemPool():RemoveCollectible(pickup.SubType)

		pickup:Morph(pickup.Type, pickup.Variant, target, true, true, true)
	end
end

return Manager