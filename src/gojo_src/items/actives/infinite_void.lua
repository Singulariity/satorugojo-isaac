local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")
local Utils = require("gojo_src.utils")

local InfiniteVoid = {}


local DOMAIN = Sprite()
DOMAIN:Load("gfx/ui/domain_expansion.anm2", true)
DOMAIN.Scale = Vector(0.5, 0.5)
DOMAIN.Color = Color(1, 1, 1, 0.23)
DOMAIN:SetFrame("Idle", 1)
local DOMAIN_ROTATE = 0


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
				entity:AddFreeze(EntityRef(player), 140)
			end
		end
	end

	Game():ShakeScreen(30)
	SFXManager():Play(enums.SOUNDS.INFINITE_VOID, 0.8)
end


---@param collectibleID CollectibleType
---@param player EntityPlayer
function InfiniteVoid.useItem(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if collectibleID ~= enums.ITEMS.INFINITE_VOID.ID then return end

	player:AnimateCollectible(collectibleID, "UseItem", "PlayerPickup")
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
		save.Data.UseCounter = save.Data.UseCounter + 2
	else
		save.Data.UseCounter = save.Data.UseCounter + 1
	end
	save.Data.DomainActive = 2
	player:EvaluateItems()

	domainExpansion()

	SFXManager():Play(enums.SOUNDS.DOMAIN_EXPANSION, 3)
	Utils:showAnimation("infinite_void.png")
end

function InfiniteVoid.postUpdate()
	if save.Data.DomainActive == 0 or save.Data.DomainTrigger < 0 then
		return
	end

	if save.Data.DomainTrigger >= 10 then
		save.Data.DomainTrigger = -1
		save.Data.DomainActive = save.Data.DomainActive - 1
		domainExpansion()
	else
		save.Data.DomainTrigger = save.Data.DomainTrigger + 1
	end
end

function InfiniteVoid.postNewRoom()
	local room = Game():GetRoom()
	if save.Data.DomainActive <= 0 or room:IsClear() or not room:IsFirstVisit() then return end

	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity:IsActiveEnemy() then
			triggerDomain()
			return
		end
	end

end

function InfiniteVoid.postNewLevel()
	save.Data.DomainActive = 0
	save.Data.DomainTrigger = -1
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function InfiniteVoid.evaluateCache(player, cacheFlag)

	if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(enums.ITEMS.INFINITE_VOID.ID) then
		local toAdd = Utils:getPlayerDamageMultiplier(player) * (0.5 + 0.2 * save.Data.UseCounter)
		player.Damage = player.Damage + toAdd
	end

	if cacheFlag == CacheFlag.CACHE_SPEED and player:HasCollectible(enums.ITEMS.INFINITE_VOID.ID) then
		player.MoveSpeed = math.min(player.MoveSpeed + 0.15, 2)
	end

	if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(enums.ITEMS.INFINITE_VOID.ID) then
		player.ShotSpeed = player.ShotSpeed + 0.2
	end
end

function InfiniteVoid.postRender()
	if not Game():GetHUD():IsVisible() then return end

    if save.Data.DomainActive > 0 then
		if not Game():IsPaused() then
			DOMAIN_ROTATE = math.fmod(DOMAIN_ROTATE + 1, 7200)
		end
		DOMAIN.Rotation = DOMAIN_ROTATE / 20

		local hud_offset = Utils:getHUDOffset()

        DOMAIN:Render(Vector(20 + hud_offset.X, 15 + hud_offset.Y))
    end
end

return InfiniteVoid