local CursedDeal = require("gojo_src.entities.cursed_deal")

---@param collectibleID CollectibleType
---@param player EntityPlayer
local function MC_PRE_USE_ITEM(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
	local ret = CursedDeal.preUseItem(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if ret ~= nil then return ret end
end

return MC_PRE_USE_ITEM