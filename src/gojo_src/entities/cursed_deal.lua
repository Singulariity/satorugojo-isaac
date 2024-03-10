local enums = require("gojo_src.core.enums")
local save = require("gojo_src.core.save_manager")

local CursedDeal = {}


---@param entity EntityPickup
function CursedDeal:isCursedDealEntity(entity)
	return entity.Variant == enums.ENTITY.CURSED_DEAL.VARIANT
end

---@param entity EntityPickup
function CursedDeal:isCursedDealCollectible(entity)
	local data = CursedDeal:getDealInfo(entity.Position)

	if data then
		return entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and true or false
	end

	return false
end

---@param position Vector
function CursedDeal:getDealInfo(position)
	local spawnSeed = Game():GetLevel():GetCurrentRoomDesc().SpawnSeed
	local tab = save.Data.CursedDeals[spawnSeed .. "." .. math.floor(position.X) .. "." .. math.floor(position.Y)]

	if tab then
		return tab
	end

	return nil
end

---@param entity EntityPickup
---@param cost table
---@param removeOtherDeals? boolean
function CursedDeal:setDealInfo(entity, cost, removeOtherDeals)
	local spawnSeed = Game():GetLevel():GetCurrentRoomDesc().SpawnSeed

	local table = {
		DealCost = cost.Cost,
		Discount = cost.Discount,
		DealEntitySeed = entity.InitSeed,
		RemoveOtherDeals = removeOtherDeals and removeOtherDeals or true,
		Picked = false
	}

	save.Data.CursedDeals[spawnSeed .. "." .. math.floor(entity.Position.X) .. "." .. math.floor(entity.Position.Y)] = table

	return table
end

---@param position Vector
function CursedDeal:deleteDealInfo(position)
	local spawnSeed = Game():GetLevel():GetCurrentRoomDesc().SpawnSeed

	save.Data.CursedDeals[spawnSeed .. "." .. math.floor(position.X) .. "." .. math.floor(position.Y)] = nil
end

---@param entity EntityPickup
function CursedDeal:updatePriceSprite(entity)
	local dealInfo = CursedDeal:getDealInfo(entity.Position)

	if dealInfo then
		local ani = dealInfo.Discount and "Discount" or "Idle"
		entity:GetSprite():SetFrame(ani, dealInfo.DealCost)
	else
		entity:Remove()
	end
end



---@param entity EntityPickup
---@return CollectibleType
function CursedDeal:getItemFromRoomPool(entity)
	local itemPool = Game():GetItemPool()

	local roomPool = itemPool:GetPoolForRoom(Game():GetRoom():GetType(), Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)
	local targetItem = itemPool:GetCollectible(roomPool, true, entity.InitSeed)

	if targetItem == 0 then
		roomPool = itemPool:GetPoolForRoom(RoomType.ROOM_BOSS, Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)
		targetItem = itemPool:GetCollectible(roomPool, true, entity.InitSeed)
	end

	return targetItem
end

---@param item CollectibleType
---@return table
function CursedDeal:evaluateCost(item)
	local itemConfig = Isaac.GetItemConfig():GetCollectible(item)
	local cost = 15

	if itemConfig then
		local quality = itemConfig.Quality
		math.randomseed(item, Game():GetLevel():GetDungeonPlacementSeed())

		if quality == 4 then
			cost = 22 + math.random(0, 6)
		elseif quality == 3 then
			cost = 16 + math.random(0, 5)
		else
			cost = 10 + math.random(quality, quality * 2)
		end

	end

	local discount = math.random(100) < 8
	return {
		Cost = discount and math.floor(cost / 2) or cost,
		Discount = discount
	}
end


--these items breaks the cursed deals
---@param collectibleID CollectibleType
---@param rngObj RNG
---@param player EntityPlayer
---@param useFlags integer
---@param activeSlot ActiveSlot
---@param varData integer
function CursedDeal.preUseItem(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if collectibleID == CollectibleType.COLLECTIBLE_MR_ME then
		local dealEntities = Isaac.FindByType(enums.ENTITY.CURSED_DEAL.ENTITY_TYPE, enums.ENTITY.CURSED_DEAL.VARIANT)
		return #dealEntities > 0 and true or nil
	end
	if collectibleID == CollectibleType.COLLECTIBLE_VOID then
		local sprite = player:GetSprite()

		if not sprite:IsPlaying("Pickup") and
		not sprite:IsPlaying("PickupWalkDown") and
		not sprite:IsPlaying("PickupWalkLeft") and
		not sprite:IsPlaying("PickupWalkUp") and
		not sprite:IsPlaying("PickupWalkRight") then
			local dealEntities = Isaac.FindByType(enums.ENTITY.CURSED_DEAL.ENTITY_TYPE, enums.ENTITY.CURSED_DEAL.VARIANT)
			return #dealEntities > 0 and true or nil
		end
	end
end

---@param entity EntityPickup
---@param collider Entity
---@param low boolean
function CursedDeal.prePickupCollision(entity, collider, low)
	if CursedDeal:isCursedDealEntity(entity) then return true end
	if not CursedDeal:isCursedDealCollectible(entity) then return end

	local player = collider:ToPlayer()
	if player and player:IsExtraAnimationFinished() then
		local dealInfo = CursedDeal:getDealInfo(entity.Position)

		if dealInfo and save.Data.CursedHearts >= dealInfo.DealCost then
			local dealEntities = Isaac.FindByType(enums.ENTITY.CURSED_DEAL.ENTITY_TYPE, enums.ENTITY.CURSED_DEAL.VARIANT)
			for _, dealEntity in ipairs(dealEntities) do
				if dealEntity.InitSeed == dealInfo.DealEntitySeed then
					dealEntity:Remove()
					break
				end
			end

			save.Data.CursedHearts = save.Data.CursedHearts - dealInfo.DealCost
			CursedDeal:deleteDealInfo(entity.Position)
			entity:GetData().CursedDealPicked = true

			if dealInfo.RemoveOtherDeals then
				local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
				for _, collectible in ipairs(collectibles) do
					local dealInfo_ = CursedDeal:getDealInfo(collectible.Position)

					if dealInfo_ then
						collectible:Remove()
					end
				end
				local dealEntities_ = Isaac.FindByType(enums.ENTITY.CURSED_DEAL.ENTITY_TYPE, enums.ENTITY.CURSED_DEAL.VARIANT)
				for _, entity_ in ipairs(dealEntities_) do
					entity_:Remove()
					CursedDeal:deleteDealInfo(entity_.Position)
				end
			end

			return
		end

	end

	return true
end


local UPDATE_PRICES = false
function CursedDeal.postUpdate()
	local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	for _, entity in ipairs(collectibles) do
		local entityData = entity:GetData()

		if entityData.CursedDealPicked then
			local pickup = entity:ToPickup()
			if pickup then
				if pickup.SubType == 0 then
					pickup:Remove()
				else
					entityData.CursedDealPicked = nil
					pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType, true, true, true)
				end
			end
		end

	end

	if UPDATE_PRICES then
		UPDATE_PRICES = false

		local dealEntities = Isaac.FindByType(enums.ENTITY.CURSED_DEAL.ENTITY_TYPE, enums.ENTITY.CURSED_DEAL.VARIANT)
		for _, entity in ipairs(dealEntities) do
			local pickup = entity:ToPickup()
			if pickup then
				CursedDeal:updatePriceSprite(pickup)
			end
		end

	end

end

---@param entity EntityPickup
function CursedDeal.postPickupInit(entity)
	if CursedDeal:isCursedDealEntity(entity) then
		--diplopia duplication fix
		if not Game():IsPaused() and Game():GetFrameCount() ~= save.Data.SaveFrame then
			entity:Remove()
			return
		end

		local dealInfo = CursedDeal:getDealInfo(entity.Position)

		if not dealInfo then
			local targetItem = entity.SubType == 0 and CursedDeal:getItemFromRoomPool(entity) or entity.SubType
			local itemConfig = Isaac.GetItemConfig():GetCollectible(targetItem)

			if not itemConfig then
				entity:Remove()
				return
			end

			CursedDeal:setDealInfo(entity, CursedDeal:evaluateCost(itemConfig.ID))
			local collectible = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemConfig.ID, entity.Position, entity.Velocity, nil)
			collectible:ToPickup().ShopItemId = -1
		end
		CursedDeal:updatePriceSprite(entity)

	elseif CursedDeal:isCursedDealCollectible(entity) then

		local itemConfig = Isaac.GetItemConfig():GetCollectible(entity.SubType)
		if itemConfig then

			local dealInfo = CursedDeal:getDealInfo(entity.Position)
			if dealInfo then
				local cost = CursedDeal:evaluateCost(itemConfig.ID)
				dealInfo.DealCost = cost.Cost
				dealInfo.Discount = cost.Discount
			end

			local sprite = entity:GetSprite()
			sprite:Load("gfx/005.100_collectible (cursed deal).anm2", false)
			if Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND > 0 then
				sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
			else
				sprite:ReplaceSpritesheet(1, itemConfig.GfxFileName)
			end
			sprite:LoadGraphics()
			sprite:SetFrame("Idle", 1)

			UPDATE_PRICES = true
		end
	end

end

---@param room Room
---@param positions table
---@param dealAmount integer
local function spawnDeals(room, positions, dealAmount)
	for i = 1, dealAmount do
		if not positions[i] then return end

		local pos = Vector((positions[i].X + 1) * 40, (positions[i].Y + 3) * 40)
		local finalPos = room:FindFreePickupSpawnPosition(pos, 0, true)
		Isaac.Spawn(enums.ENTITY.CURSED_DEAL.ENTITY_TYPE, enums.ENTITY.CURSED_DEAL.VARIANT, 0, finalPos, Vector(0, 0), nil)
	end
end

local DEAL_SPAWNS = {
	[tostring(RoomType.ROOM_SHOP)] = {
		---x   min = 1, max = 13
		---y   min = 1, max = 7
		["0"] = {
			Vector(4, 5),
			Vector(10, 5),
			Vector(5, 3),
			Vector(9, 3)
		},
		["1"] = {
			Vector(3, 5),
			Vector(11, 5),
			Vector(5, 3),
			Vector(9, 3)
		},
		["2"] = {
			Vector(3, 3),
			Vector(11, 3),
			Vector(2, 6),
			Vector(12, 6)
		},
		["3"] = {
			Vector(5, 3),
			Vector(9, 3),
			Vector(2, 2),
			Vector(12, 2)
		},
		["4"] = {
			Vector(2, 6),
			Vector(12, 6),
			Vector(3, 3),
			Vector(11, 3)
		},
		["5"] = {
			Vector(4, 7),
			Vector(10, 7),
			Vector(1, 1),
			Vector(13, 1)
		},
		["6"] = {
			Vector(3, 6),
			Vector(11, 2)
		},
		["14"] = {
			Vector(4, 5),
			Vector(10, 5),
			Vector(5, 3),
			Vector(9, 3)
		},
		["15"] = {
			Vector(3, 5),
			Vector(11, 5),
			Vector(5, 3),
			Vector(9, 3)
		},
		["16"] = {
			Vector(3, 6),
			Vector(11, 6),
			Vector(6, 3),
			Vector(8, 3)
		},
		["17"] = {
			Vector(3, 5),
			Vector(11, 5),
			Vector(4, 3),
			Vector(10, 3)
		}
	},
	[tostring(RoomType.ROOM_BLACK_MARKET)] = {
		---x   min = 1, max = 26
		---y   min = 1, max = 7
		["0"] = {
			Vector(12, 2),
			Vector(18, 2),
			Vector(10, 2),
			Vector(20, 2)
		},
		["1"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(15, 5)
		},
		["2"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(14, 6),
			Vector(16, 6)
		},
		["3"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(14, 6),
			Vector(16, 6)
		},
		["4"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(15, 5)
		},
		["5"] = {
			Vector(12, 2),
			Vector(18, 2),
			Vector(9, 4),
			Vector(21, 4),
		},
		["6"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(14, 6),
			Vector(16, 6)
		},
		["8"] = {
			Vector(13, 4),
			Vector(17, 4),
		},
		["9"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(14, 6),
			Vector(16, 6)
		},
		["10"] = {
			Vector(12, 6),
			Vector(18, 6),
			Vector(14, 6),
			Vector(16, 6)
		},
		["11"] = {
			Vector(12, 2),
			Vector(18, 2),
			Vector(10, 2),
			Vector(20, 2)
		}
	}
}

function CursedDeal.postNewRoom()
	if Isaac.GetPlayer():GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	local room = Game():GetRoom()
	local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
	if room:IsFirstVisit() and not roomDesc.SurpriseMiniboss and not room:IsMirrorWorld() then
		local roomType = room:GetType()
		local tab = DEAL_SPAWNS[tostring(roomType)]

		if tab then
			local roomVariant = roomDesc.Data.Variant
			local positions = tab[tostring(roomVariant)]

			if positions then
				local dealAmount = 2
				math.randomseed(roomDesc.SpawnSeed)
				if math.random(1, 100) < 15 then
					dealAmount = dealAmount + 2
				end
				spawnDeals(room, positions, dealAmount)
			end
		end

	end
end

return CursedDeal