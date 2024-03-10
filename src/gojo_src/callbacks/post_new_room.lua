local InfiniteVoid = require("gojo_src.items.actives.infinite_void")
local CursedDeal = require("gojo_src.entities.cursed_deal")
local eid = require("gojo_src.mods.eid")

local function MC_POST_NEW_ROOM()
	InfiniteVoid.postNewRoom()
	CursedDeal.postNewRoom()

	eid.postNewRoom()
end

return MC_POST_NEW_ROOM