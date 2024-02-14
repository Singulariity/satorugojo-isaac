local save = require("gojo_src.core.save_manager")
local enums = require("gojo_src.core.enums")
local Utils = require("gojo_src.utils")

local Manager = {}

---@param id CollectibleType
function Manager:isUnlocked(id)
	local item
	for i, _ in pairs(enums.ITEMS) do
		if enums.ITEMS[i].ID == id then
			item = enums.ITEMS[i]
			break
		end
	end

	if not item then return false end

	if item.Completion then
		local tab = save.Data.PermanentData.Unlocks[tostring(item.Character)][item.Completion]
		if item.Hard then
			return tab.Hard
		else
			return tab.Unlock
		end
	end
	return true
end

---@param completion Completion
---@param difficulty Difficulty
local function UpdateCompletion(completion, difficulty)
	local hard = difficulty == Difficulty.DIFFICULTY_HARD or difficulty == Difficulty.DIFFICULTY_GREEDIER

	for p = 0, Game():GetNumPlayers() - 1 do
		local playerType = Isaac.GetPlayer(p):GetPlayerType()
		local tab = save.Data.PermanentData.Unlocks[tostring(playerType)]

		if not tab then goto continue end

		local newUnlock = false

		if not tab[completion].Unlock then
			Isaac.DebugString("Gojo - Completed: " .. completion)
			tab[completion].Unlock = true
			newUnlock = true
		end
		if hard and not tab[completion].Hard then
			Isaac.DebugString("Gojo - Completed (Hard): " .. completion)
			tab[completion].Hard = true
			newUnlock = true
		end

		if newUnlock then
			for i, _ in pairs(enums.ITEMS) do
				local item = enums.ITEMS[i]

				if item.Completion and item.Completion == completion then
					if not item.Hard then
						Utils:ShowAchievement(item.Achievement)
					elseif hard then
						Utils:ShowAchievement(item.Achievement)
					end
				end

			end
		end

		::continue::
	end
end

local UnlockFunctions = {
	--Heart & Mother
	[LevelStage.STAGE4_2] = function(room, stageType, difficulty, desc)
		if room:IsClear() then
			local completion

			if stageType >= StageType.STAGETYPE_REPENTANCE and desc.SafeGridIndex == -10 then
				completion = enums.COMPLETION.Mother
			elseif stageType <= StageType.STAGETYPE_AFTERBIRTH and room:IsCurrentRoomLastBoss() then
				completion = enums.COMPLETION.MomsHeart
			end

			if completion then
				UpdateCompletion(completion, difficulty)
			end
		end
	end,
	--Hush
	[LevelStage.STAGE4_3] = function(room, stageType, difficulty, desc)
		if room:IsClear() then
			UpdateCompletion(enums.COMPLETION.Hush, difficulty)
		end
	end,
	--Satan & Isaac
	[LevelStage.STAGE5] = function(room, stageType, difficulty, desc)
		if room:IsClear() then
			local completion = enums.COMPLETION.Satan
			if stageType == StageType.STAGETYPE_WOTL then
				completion = enums.COMPLETION.Isaac
			end

			UpdateCompletion(completion, difficulty)
		end
	end,
	--Mega Satan & Lamb & BlueBaby
	[LevelStage.STAGE6] = function(room, stageType, difficulty, desc)
		if desc.SafeGridIndex == -7 then
			local MegaSatan

			for _, satan in ipairs(Isaac.FindByType(EntityType.ENTITY_MEGA_SATAN_2, 0)) do
				MegaSatan = satan
				break
			end

			if not MegaSatan then return end

			local sprite = MegaSatan:GetSprite()

			if sprite:IsPlaying("Death") and sprite:GetFrame() == 110 then
				UpdateCompletion(enums.COMPLETION.MegaSatan, difficulty)
			end
		else
			if room:IsClear() then
				local completion = enums.COMPLETION.Lamb
				if stageType == StageType.STAGETYPE_WOTL then
					completion = enums.COMPLETION.BlueBaby
				end

				UpdateCompletion(completion, difficulty)
			end
		end
	end,
	--Delirium
	[LevelStage.STAGE7] = function(room, stageType, difficulty, desc)
		if desc.Data.Subtype == 70 and room:IsClear() then
			local completion = enums.COMPLETION.Delirium

			UpdateCompletion(completion, difficulty)
		end
	end,
	--BossRush
	BossRush = function(room, stageType, difficulty, desc)
		if room:IsAmbushDone() then
			UpdateCompletion(enums.COMPLETION.BossRush, difficulty)
		end
	end,
	--Beast
	Beast = function(room, stageType, difficulty, desc)
		local Beast

		for _, beast in ipairs(Isaac.FindByType(EntityType.ENTITY_BEAST, 0)) do
			Beast = beast
			break
		end

		if not Beast then return end

		local sprite = Beast:GetSprite()

		if sprite:IsPlaying("Death") and sprite:GetFrame() == 30 then
			UpdateCompletion(enums.COMPLETION.Beast, difficulty)
		end
	end,
	Greed = function(room, stageType, difficulty, desc) -- Greed
		if room:IsClear() then
			UpdateCompletion(enums.COMPLETION.GreedMode, difficulty)
		end
	end
}

function Manager.postUpdate()
	local level = Game():GetLevel()
	local room = Game():GetRoom()
	local desc = level:GetCurrentRoomDesc()
	local levelStage = level:GetStage()
	local roomType = room:GetType()
	local difficulty = Game().Difficulty

	if Isaac.GetChallenge() ~= 0 or Game():GetVictoryLap() > 0 then
		return
	end

	if difficulty <= Difficulty.DIFFICULTY_HARD then
		local stageType = level:GetStageType()

		if levelStage == LevelStage.STAGE4_1 and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0 then
			levelStage = levelStage + 1
		end

		if roomType == RoomType.ROOM_BOSS and UnlockFunctions[levelStage] then
			UnlockFunctions[levelStage](room, stageType, difficulty, desc)
		elseif roomType == RoomType.ROOM_BOSSRUSH then
			UnlockFunctions.BossRush(room, stageType, difficulty, desc)
		elseif levelStage == LevelStage.STAGE8 and roomType == RoomType.ROOM_DUNGEON then
			UnlockFunctions.Beast(room, stageType, difficulty, desc)
		end
	else
		if levelStage == LevelStage.STAGE7_GREED and roomType == RoomType.ROOM_BOSS and desc.SafeGridIndex == 45 then
			UnlockFunctions.Greed(room, nil, difficulty, desc)
		end
	end
end

---@param player EntityPlayer
function Manager.postPlayerInit(player)
	for i, _ in pairs(enums.ITEMS) do
		local item = enums.ITEMS[i]
		if not Manager:isUnlocked(item.ID) then
			Game():GetItemPool():RemoveCollectible(item.ID)
		end
	end
end

--currently unused
---@param pickup EntityPickup
function Manager.postPickupInit(pickup)
	if true then return end
	if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end

	local item = enums:getItemById(pickup.SubType)
	if not item then return end

	if not Manager:isUnlocked(pickup.SubType) then
		local pool = Game():GetItemPool():GetPoolForRoom(Game():GetRoom():GetType(), Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)
		local target = Game():GetItemPool():GetCollectible(pool, true, pickup.InitSeed)
		Game():GetItemPool():RemoveCollectible(pickup.SubType)

		pickup:Morph(pickup.Type, pickup.Variant, target, true, true, true)
	end
end

return Manager