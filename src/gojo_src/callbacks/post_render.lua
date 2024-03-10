local Gojo = require("gojo_src.characters.gojo")
local eid = require("gojo_src.mods.eid")
local InfiniteVoid = require("gojo_src.items.actives.infinite_void")

local function MC_POST_RENDER()
	InfiniteVoid.postRender()
	Gojo.postRender()
	eid.postRender()
end

return MC_POST_RENDER