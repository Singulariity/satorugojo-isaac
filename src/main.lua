GojoMod = RegisterMod("Satoru Gojo", 1)

local save = require("gojo_src.core.save_manager")
save.SaveManager.Init(GojoMod)

--callbacks
local evaluateCache = require("gojo_src.callbacks.evaluate_cache")
local postNewLevel = require("gojo_src.callbacks.post_new_level")
local postNewRoom = require("gojo_src.callbacks.post_new_room")
local postPlayerInit = require("gojo_src.callbacks.post_player_init")
local postUpdate = require("gojo_src.callbacks.post_update")
local preGameExit = require("gojo_src.callbacks.pre_game_exit")
local useItem = require("gojo_src.callbacks.use_item")

--TODO add EID update to player init
GojoMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evaluateCache)
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewLevel)
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
GojoMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit)
GojoMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)
GojoMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, preGameExit)
GojoMod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem)


--other
local eid = require("gojo_src.mods.eid")
eid:UpdateEID()