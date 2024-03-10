local InfiniteVoid = require("gojo_src.items.actives.infinite_void")
local CursedHeart = require("gojo_src.entities.cursed_heart")
local CursedDeal = require("gojo_src.entities.cursed_deal")
local unlock = require("gojo_src.core.unlock_manager")
local once = require("gojo_src.core.once_manager")

local function MC_POST_UPDATE()
	InfiniteVoid.postUpdate()
	CursedHeart.postUpdate()
	CursedDeal.postUpdate()

	unlock.postUpdate()
	once.postUpdate()
end

return MC_POST_UPDATE