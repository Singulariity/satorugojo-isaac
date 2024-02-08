local Limit = require("gojo_src.items.passives.limit")

---@param player EntityPlayer
local function MC_POST_PEFFECT_UPDATE(_, player)
	Limit.postPEffectUpdate(player)
end

return MC_POST_PEFFECT_UPDATE