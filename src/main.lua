GojoMod = RegisterMod("Satoru Gojo", 1)

local enums = require("gojo_src.core.enums")
local save = require("gojo_src.core.save_manager")
save.SaveManager.Init(GojoMod)

--callbacks
local evaluateCache = require("gojo_src.callbacks.evaluate_cache")
local postNewLevel = require("gojo_src.callbacks.post_new_level")
local postNewRoom = require("gojo_src.callbacks.post_new_room")
local postPickupInit = require("gojo_src.callbacks.post_pickup_init")
local postPlayerInit = require("gojo_src.callbacks.post_player_init")
local postPEffectUpdate = require("gojo_src.callbacks.post_peffect_update")
local postUpdate = require("gojo_src.callbacks.post_update")
local preGameExit = require("gojo_src.callbacks.pre_game_exit")
local useItem = require("gojo_src.callbacks.use_item")

GojoMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evaluateCache)
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewLevel)
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
GojoMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit)
GojoMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit)
GojoMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPEffectUpdate)
GojoMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)
GojoMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, preGameExit)
GojoMod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem)


--other
include("gojo_src.mods.pause_screen_completion_marks_api")
PauseScreenCompletionMarksAPI:AddModCharacterCallback(enums.PLAYERS.GOJO, function()
	return save.Data.PermanentData.Unlocks[tostring(enums.PLAYERS.GOJO)]
end)
local eid = require("gojo_src.mods.eid")
eid:UpdateEID()


--test
local function Dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. Dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end
local once = require("gojo_src.core.once_manager")
---@param player EntityPlayer
function Test(_, player)
end
GojoMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Test)