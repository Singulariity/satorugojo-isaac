local unlock = require("gojo_src.core.unlock_manager")

---@param pickup EntityPickup
local function MC_POST_PICKUP_INIT(_, pickup)
	unlock.postPickupInit(pickup)
end

return MC_POST_PICKUP_INIT