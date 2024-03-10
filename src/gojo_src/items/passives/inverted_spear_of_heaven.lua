local enums = require("gojo_src.core.enums")

local InvertedSpearOfHeaven = {}

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function InvertedSpearOfHeaven.evaluateCache(player, cacheFlag)

	if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(enums.ITEMS.INVERTED_SPEAR_OF_HEAVEN.ID) then
		local itemAmount = player:GetCollectibleNum(enums.ITEMS.INVERTED_SPEAR_OF_HEAVEN.ID)
		player.Damage = player.Damage + (itemAmount * 2.5)
	end

end

return InvertedSpearOfHeaven