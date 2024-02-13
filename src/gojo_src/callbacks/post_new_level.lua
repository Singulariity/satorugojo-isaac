local InfiniteVoid = require("gojo_src.items.actives.infinite_void")
local save = require("gojo_src.core.save_manager")

local function MC_POST_NEW_LEVEL()
	save.SaveManager.postNewLevel()

	InfiniteVoid.postNewLevel()
end

return MC_POST_NEW_LEVEL