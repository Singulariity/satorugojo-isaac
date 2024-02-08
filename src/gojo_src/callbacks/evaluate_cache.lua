local InfiniteVoid =  require("gojo_src.items.actives.infinite_void")
local Gojo = require("gojo_src.characters.gojo")

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function MC_EVALUATE_CACHE(_, player, cacheFlag)
	InfiniteVoid.evaluateCache(player, cacheFlag)
	Gojo.evaluateCache(player, cacheFlag)
end

return MC_EVALUATE_CACHE