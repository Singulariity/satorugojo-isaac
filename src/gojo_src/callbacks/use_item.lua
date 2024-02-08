local InfiniteVoid = require("gojo_src.items.actives.infinite_void")

---@param collectibleID CollectibleType
---@param player EntityPlayer
local function MC_USE_ITEM(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
	InfiniteVoid.useItem(collectibleID, rngObj, player, useFlags, activeSlot, varData)
end

return MC_USE_ITEM