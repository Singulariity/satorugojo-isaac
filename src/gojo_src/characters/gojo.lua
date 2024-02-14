local once = require("gojo_src.core.once_manager")
local enums = require("gojo_src.core.enums")
local save = require("gojo_src.core.save_manager")

local Gojo = {}


---@param player EntityPlayer
function Gojo:giveNullCostume(player)
	player:TryRemoveNullCostume(enums.COSTUMES.GOJO_HAIR)
	player:AddNullCostume(enums.COSTUMES.GOJO_HAIR)
end

---@param player EntityPlayer
function Gojo.postPlayerInit(player)
	if player:GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	Gojo:giveNullCostume(player)

	local continue = Game():GetFrameCount() ~= 0

	if not continue then
		player:AddCollectible(enums.ITEMS.INFINITE_VOID.ID, 4, true)
	end
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function Gojo.evaluateCache(player, cacheFlag)
	if player:GetPlayerType() ~= enums.PLAYERS.GOJO.ID then return end

	--when the player picks up "Missing No." item, the null costume disappears
	--hacky way to fix it but anyways ;D
	if once:useOnce("costume") then
		Gojo:giveNullCostume(player)
	end

	if not save.Data.Birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		save.Data.Birthright = true
		SFXManager():Play(enums.SOUNDS.GOJO_BIRTHRIGHT)
	end

end

return Gojo