local InfiniteVoid =  require("gojo_src.items.actives.infinite_void")
local Limit =  require("gojo_src.items.passives.limit")
local Gojo = require("gojo_src.characters.gojo")
local eid = require("gojo_src.mods.eid")

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function MC_EVALUATE_CACHE(_, player, cacheFlag)
	InfiniteVoid.evaluateCache(player, cacheFlag)
	Limit.evaluateCache(player, cacheFlag)
	Gojo.evaluateCache(player, cacheFlag)

	eid.evaluateCache(player, cacheFlag)
end

return MC_EVALUATE_CACHE