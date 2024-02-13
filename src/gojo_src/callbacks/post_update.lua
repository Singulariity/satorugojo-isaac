local InfiniteVoid = require("gojo_src.items.actives.infinite_void")
local unlock = require("gojo_src.core.unlock_manager")
local once = require("gojo_src.core.once_manager")

local function MC_POST_UPDATE()
	InfiniteVoid.postUpdate()
	unlock.postUpdate()
	once.postUpdate()
end

return MC_POST_UPDATE