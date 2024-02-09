local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")
local Utils = require("gojo_src.utils")

local InfiniteVoid = {}

local function triggerDomain()
	save.Data.DomainTrigger = 0
end

local function domainExpansion()
	local player = Isaac.GetPlayer()
	local roomEntities = Isaac.GetRoomEntities()
	for _, entity in ipairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_PROJECTILE then
			entity:Die()
		elseif entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
			if not entity:IsBoss() or save.Data.UseCounter >= 5 then
				entity:AddFreeze(EntityRef(player), 130)
			end
		end
	end

	Game():ShakeScreen(30)
	SFXManager():Play(enums.SOUNDS.INFINITE_VOID, 0.8)
end


---@param collectibleID CollectibleType
---@param player EntityPlayer
function InfiniteVoid.useItem(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if collectibleID ~= enums.ITEMS.INFINITE_VOID then return end

	player:AnimateCollectible(collectibleID, "UseItem", "PlayerPickup")
	save.Data.DomainActive = 2
	save.Data.UseCounter = save.Data.UseCounter + 1
	player:EvaluateItems()

	domainExpansion()

	SFXManager():Play(enums.SOUNDS.DOMAIN_EXPANSION, 3)
	Utils:showAnimation("blackhole.png")
end

function InfiniteVoid.postUpdate()
	if save.Data.DomainActive == 0 or save.Data.DomainTrigger < 0 then
		return
	end

	local start = save.Data.DomainTrigger

	if start >= 10 then
		save.Data.DomainTrigger = -1
		save.Data.DomainActive = save.Data.DomainActive - 1
		domainExpansion()
	else
		save.Data.DomainTrigger = save.Data.DomainTrigger + 1
	end
end

function InfiniteVoid.postNewRoom()
	if save.Data.DomainActive > 0 and not Game():GetRoom():IsClear() then
		triggerDomain()
	end
end

function InfiniteVoid.postNewLevel()
	save.Data.DomainActive = 0
	save.Data.DomainTrigger = -1
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function InfiniteVoid.evaluateCache(player, cacheFlag)

	if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(enums.ITEMS.INFINITE_VOID) then
		player.Damage = player.Damage + 0.5 + (0.2 * math.min(save.Data.UseCounter, 10))
	end

	if cacheFlag == CacheFlag.CACHE_SPEED and player:HasCollectible(enums.ITEMS.INFINITE_VOID) then
		player.MoveSpeed = math.min(player.MoveSpeed + 0.15, 2)
	end

	if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(enums.ITEMS.INFINITE_VOID) then
		player.ShotSpeed = player.ShotSpeed + 0.2
	end

	if player:HasCollectible(enums.ITEMS.INFINITE_VOID) and not Utils:hasValue(save.Data.TransformationPickIDs, enums.ITEMS.INFINITE_VOID) then
		table.insert(save.Data.TransformationPickIDs, enums.ITEMS.INFINITE_VOID)
	end
end

return InfiniteVoid