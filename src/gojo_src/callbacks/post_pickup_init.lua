local Gojo = require("gojo_src.characters.gojo")
local CursedDeal = require("gojo_src.entities.cursed_deal")

---@param pickup EntityPickup
local function MC_POST_PICKUP_INIT(_, pickup)
	Gojo.postPickupInit(pickup)
	CursedDeal.postPickupInit(pickup)
end

return MC_POST_PICKUP_INIT