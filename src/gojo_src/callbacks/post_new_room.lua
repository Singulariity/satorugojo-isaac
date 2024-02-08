local InfiniteVoid =  require("gojo_src.items.actives.infinite_void")
local eid = require("gojo_src.mods.eid")

local function MC_POST_NEW_ROOM()
	InfiniteVoid.postNewRoom()

	eid.postNewRoom()
end

return MC_POST_NEW_ROOM