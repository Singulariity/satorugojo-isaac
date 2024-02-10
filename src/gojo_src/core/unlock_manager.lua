local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")
local Utils = require("gojo_src.utils")

local Manager = {}

---@param id CollectibleType
---@param showAchievement boolean? default: `false`
function Manager:unlockItembyId(id, showAchievement)
	local item = enums:getItemById(id)
	if not item then return end

	save.Data.PermanentData.Unlocks[item.Name] = true
	if showAchievement then
		Utils:ShowAchievement(item.Achievement)
	end
end

---@param id CollectibleType
function Manager:isUnlocked(id)
	local item
	for i, _ in pairs(enums.ITEMS) do
		if enums.ITEMS[i].ID == id then
			item = enums.ITEMS[i]
			goto continue
		end
	end
	::continue::

	if item and (item.UnlockedDefault or save.Data.PermanentData.Unlocks[item.Name]) then
		return true
	end
	return false
end

---@param entity Entity
function Manager.postEntityKill(entity)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() ~= enums.PLAYERS.GOJO then return end

	for i, _ in pairs(enums.ITEMS) do
		local item = enums.ITEMS[i]

		if item.UnlockBoss ~= entity.Type then goto continue end

		if not Manager:isUnlocked(item.ID) then
			Manager:unlockItembyId(item.ID, true)
		end
		::continue::
	end

end

---@param pickup EntityPickup
function Manager.postPickupInit(pickup)
	if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end

	local item = enums:getItemById(pickup.SubType)
	if not item then return end

	if not Manager:isUnlocked(pickup.SubType) then
		local pool = Game():GetItemPool():GetPoolForRoom(Game():GetRoom():GetType(), Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)
		local target = Game():GetItemPool():GetCollectible(pool, true, pickup.InitSeed)
		Game():GetItemPool():RemoveCollectible(pickup.SubType)

		pickup:Morph(pickup.Type, pickup.Variant, target, true, true, true)
	end
end

return Manager