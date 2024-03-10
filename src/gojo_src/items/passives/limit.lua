local enums = require("gojo_src.core.enums")

local Limit = {}

---@param player EntityPlayer
function Limit.postPEffectUpdate(player)
	if not player:HasCollectible(enums.ITEMS.LIMIT.ID) then return end

	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity.Type == EntityType.ENTITY_PROJECTILE then
			local proj = entity:ToProjectile()
			if not proj or proj.SpawnerType == EntityType.ENTITY_PLAYER then goto continue end

			local distance = math.sqrt(proj.Position:Distance(player.Position))
			if distance < 9 then
				local mul = -0.15 - (0.85 * (0.5 / distance))
				local new = Vector(mul * proj.Velocity.X, mul * proj.Velocity.Y)
				proj:AddVelocity(new)
			end
		end
		::continue::
	end
end

return Limit