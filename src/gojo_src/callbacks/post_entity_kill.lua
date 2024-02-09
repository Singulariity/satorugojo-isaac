local unlock = require("gojo_src.core.unlock_manager")

---@param entity Entity
local function MC_POST_ENTITY_KILL(_, entity)
	unlock.postEntityKill(entity)
end

return MC_POST_ENTITY_KILL