local once = require("gojo_src.core.once_manager")
local enums = require("gojo_src.core.enums")
local save = require("gojo_src.core.save_manager")
local CursedHeart = require("gojo_src.entities.cursed_heart")
local Utils = require("gojo_src.utils")

local Gojo = {}


local HUD = Sprite()
HUD:Load("gfx/ui/gojo_hud.anm2", true)
HUD:SetFrame("Idle", 1)

local NUM_FONT = Font()
NUM_FONT:Load("font/pftempestasevencondensed.fnt")

local UI_LAYOUTS = {
	CURSED_HEART_ICON_X = 27,
	CURSED_HEART_ICON_Y = 32,

	CURSED_HEART_TEXT_X = 43,
	CURSED_HEART_TEXT_Y = 33,
}


---@param player EntityPlayer
function Gojo:giveNullCostume(player)
	player:TryRemoveNullCostume(enums.COSTUMES.GOJO_HAIR)
	--player:TryRemoveNullCostume(enums.COSTUMES.GOJO_BODY)
	player:AddNullCostume(enums.COSTUMES.GOJO_HAIR)
	--player:AddNullCostume(enums.COSTUMES.GOJO_BODY)
end


---@param player EntityPlayer
function Gojo.postPlayerInit(player)
	if player:GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	Gojo:giveNullCostume(player)

	local continue = Game():GetFrameCount() ~= 0
	if not continue then
		player:AddCollectible(enums.ITEMS.INFINITE_VOID.ID, 4, true)
	end
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function Gojo.evaluateCache(player, cacheFlag)
	if player:GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	--when the player picks up "Missing No." item, the null costume disappears
	--hacky way to fix it but anyways ;D
	if once:useOnce("costume") then
		Gojo:giveNullCostume(player)
	end

	if not save.Data.Birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		save.Data.Birthright = true
		SFXManager():Play(enums.SOUNDS.GOJO_BIRTHRIGHT)

		local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
		for _, entity in ipairs(entities) do
			if entity.Variant == PickupVariant.PICKUP_HEART and (entity.SubType == HeartSubType.HEART_FULL or entity.SubType == HeartSubType.HEART_HALF) then
				local subType = entity.SubType == HeartSubType.HEART_FULL and enums.ENTITY.CURSED_HEART.SUBTYPE or enums.ENTITY.CURSED_HEART_HALF.SUBTYPE
				entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, subType, true, true)
			end
		end
	end

end

---@param entity EntityPickup
function Gojo.postPickupInit(entity)
	if Isaac.GetPlayer():GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	if CursedHeart:isCursedHeart(entity) then return end

	if entity.Variant == PickupVariant.PICKUP_HEART and (entity.SubType == HeartSubType.HEART_FULL or entity.SubType == HeartSubType.HEART_HALF) then
		if not Isaac.GetPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			math.randomseed(entity.InitSeed)
			if math.random(100) > 30 then return end
		end

		local subType = entity.SubType == HeartSubType.HEART_FULL and enums.ENTITY.CURSED_HEART.SUBTYPE or enums.ENTITY.CURSED_HEART_HALF.SUBTYPE
		entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, subType, true, true)
	end
end

function Gojo.postRender()
	if Isaac.GetPlayer():GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	if not Game():GetHUD():IsVisible() then return end

	local hud_offset = Utils:getHUDOffset()

	--render icon
	local icon_X = UI_LAYOUTS.CURSED_HEART_ICON_X + hud_offset.X
	local icon_Y = UI_LAYOUTS.CURSED_HEART_ICON_Y + hud_offset.Y
	HUD:RenderLayer(0, Vector(icon_X, icon_Y))

	--render stat string
	local num = string.format("%02d", save.Data.CursedHearts)
	local text_X = UI_LAYOUTS.CURSED_HEART_TEXT_X + hud_offset.X + Game().ScreenShakeOffset.X
	local text_Y = UI_LAYOUTS.CURSED_HEART_TEXT_Y + hud_offset.Y + Game().ScreenShakeOffset.Y
	NUM_FONT:DrawString(num, text_X, text_Y, KColor(1, 1, 1, 1))
end

return Gojo