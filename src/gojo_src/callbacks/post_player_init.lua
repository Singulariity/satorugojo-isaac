local Gojo = require("gojo_src.characters.gojo")
local save = require("gojo_src.core.save_manager")
local unlock = require("gojo_src.core.unlock_manager")

---@param player EntityPlayer
local function MC_POST_PLAYER_INIT(_, player)
	save.SaveManager.postPlayerInit(player)
	unlock.postPlayerInit(player)

	Gojo.postPlayerInit(player)
end

return MC_POST_PLAYER_INIT