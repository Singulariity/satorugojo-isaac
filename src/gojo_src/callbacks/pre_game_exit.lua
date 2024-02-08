local save = require("gojo_src.core.save_manager")

---when the game is closed normally
local function MC_PRE_GAME_EXIT(_)
	save.SaveManager.preGameExit()
end

return MC_PRE_GAME_EXIT