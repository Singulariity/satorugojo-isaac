local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")


local CursedHeart = {}

---@param entity EntityPickup
function CursedHeart:isCursedHeart(entity)
	if entity.Variant == PickupVariant.PICKUP_HEART and (entity.SubType == enums.ENTITY.CURSED_HEART.SUBTYPE or entity.SubType == enums.ENTITY.CURSED_HEART_HALF.SUBTYPE) then
		return true
	end
	return false
end

---@param entity Entity
local function cursedHeartPost(entity)
	local sprite = entity:GetSprite()

	if sprite:IsPlaying("Appear") and sprite:IsEventTriggered("DropSound") then
		SFXManager():Play(SoundEffect.SOUND_MEAT_FEET_SLOW0)
	end

	if entity:GetData().Picked then
		if sprite:IsPlaying("Collect") then
			if sprite:GetFrame() > 5 then
				entity:Remove()
			end
		else
			sprite:Play("Collect", true)
		end
	end
end

function CursedHeart.postUpdate()
	local cursed_hearts = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, enums.ENTITY.CURSED_HEART.SUBTYPE)
	local half_cursed_hearts = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, enums.ENTITY.CURSED_HEART_HALF.SUBTYPE)

	for _, entity in ipairs(cursed_hearts) do
		cursedHeartPost(entity)
	end
	for _, entity in ipairs(half_cursed_hearts) do
		cursedHeartPost(entity)
	end

end

---@param entity EntityPickup
---@param collider Entity
---@param low boolean
function CursedHeart.prePickupCollision(entity, collider, low)
	if not CursedHeart:isCursedHeart(entity) then return end

	local player = collider:ToPlayer()

	if not player then return end

	local sprite = entity:GetSprite()
	local entityData = entity:GetData()

	if sprite:IsPlaying("Idle")
	and not entityData.Picked
	and save.Data.CursedHearts < 99
	and player:GetDamageCooldown() == 0
	and player:GetNumCoins() >= entity.Price
	then
		local isCursed
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			isCursed = false
		else
			local cursedChance = 70 * math.max((1 + player:GetHearts()) / player:GetEffectiveMaxHearts(), 0.55)
			isCursed = entity:GetDropRNG():RandomInt(100) < cursedChance
		end

		sprite:Play("Collect", true)
		if isCursed then
			SFXManager():Play(enums.SOUNDS.CURSED_HEART_COLLECT)
		else
			SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES)
		end
		entityData.Picked = true
		if entity.Price > 0 then
			player:AddCoins(-1 * entity.Price)
		end

		--pick up
		math.randomseed(entity.InitSeed)
		local amount = entity.SubType == enums.ENTITY.CURSED_HEART.SUBTYPE and 2 or 1
		local toAdd = 0
		if isCursed then
			player:TakeDamage(amount, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(entity), 60)
			toAdd = amount + math.random(0, 1) + (math.random(0, 1) == 0 and amount - 1 or 0)
		else
			local max_red = player:GetEffectiveMaxHearts()
			local current_red = player:GetHearts()
			local empty_red = max_red - current_red
			local new_amount = math.max(amount - empty_red, 0)
			toAdd = new_amount + math.random(0, 1) + (math.random(0, 1) == 0 and new_amount - 1 or 0)

			player:AddHearts(amount)
		end

		if toAdd > 0 then
			save.Data.CursedHearts = math.min(save.Data.CursedHearts + toAdd, 99)
		end

	end

	if entityData.Picked then return true end
end

return CursedHeart