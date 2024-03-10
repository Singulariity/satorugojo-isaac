local CursedHeart = require("gojo_src.entities.cursed_heart")
local CursedDeal = require("gojo_src.entities.cursed_deal")

---@param entity EntityPickup
---@param collider Entity
---@param low boolean
local function MC_PRE_PICKUP_COLLISION(_, entity, collider, low)
	local ret = CursedHeart.prePickupCollision(entity, collider, low)
	if ret ~= nil then return ret end

	ret = CursedDeal.prePickupCollision(entity, collider, low)
	if ret ~= nil then return ret end
end

return MC_PRE_PICKUP_COLLISION