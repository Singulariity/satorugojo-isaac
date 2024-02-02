local json = require("json")

GojoMod = RegisterMod("Satoru Gojo", 1)

local DefaultData = {
	["DomainActive"] = false,
	["UseCounter"] = 0,
	["BirthrightPickedUp"] = false
}

local ModData = {}

SoundEffect.DOMAIN_EXPANSION = Isaac.GetSoundIdByName("Domain Expansion")
SoundEffect.GOJO_BIRTHRIGHT = Isaac.GetSoundIdByName("Gojo Birthright")
CollectibleType.INFINITE_VOID = Isaac.GetItemIdByName("Infinite Void")

--TODO accurate stats in descriptions
---IED item descriptions
if EID then
	EID:addCollectible(CollectibleType.INFINITE_VOID, "↑ {{Damage}} +2 Damage#{{Blank}} {{Damage}} Bonus +0.2 per use#↑ {{Speed}} +0.3 Speed#↑ {{Shotspeed}} +0.2 Shot speed#When activated:#{{Blank}} \7 Vulnerable non-boss enemies will petrify for a moment when you enter a room for the current floor#{{Blank}} \7 Also petrifies bosses after 5 usages#{{TreasureRoomChanceSmall}} {{ColorSilver}}Throughout heaven and earth, I alone am the {{ColorRainbow}}Honored One{{ColorSilver}}.")
end



---@param image string
local function showAnimation(image)
	if GiantBookAPI then
		GiantBookAPI.playGiantBook("Appear", image, Color(0.2, 0/5, 1, 0), Color(0, 0, 0, 1), Color(0, 0, 0, 1))
	end
end


local function freezeAllEnemies()
	local player = Isaac.GetPlayer(0)
	local roomEntities = Isaac.GetRoomEntities()

	for _, entity in ipairs(roomEntities) do
		if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
			if not entity:IsBoss() or ModData["UseCounter"] >= 5 then
				entity:AddFreeze(EntityRef(player), 90)
			end
		end
	end

end


---@param player EntityPlayer
function GojoMod:onUseInfiniteVoid(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	player:AnimateCollectible(CollectibleType.INFINITE_VOID, "UseItem", "PlayerPickup")
	ModData["DomainActive"] = true
	ModData["UseCounter"] = ModData["UseCounter"] + 1
	player:EvaluateItems()

	freezeAllEnemies()

	SFXManager():Play(SoundEffect.DOMAIN_EXPANSION, 3)
	showAnimation("blackhole.png")
end
GojoMod:AddCallback(ModCallbacks.MC_USE_ITEM, GojoMod.onUseInfiniteVoid, CollectibleType.INFINITE_VOID)


---@param player EntityPlayer
---@param cacheFlag CacheFlag
function GojoMod:onCache(player, cacheFlag)
	if player == nil then return end

	if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(CollectibleType.INFINITE_VOID) then
		player.Damage = player.Damage + 2 + (0.2 * ModData["UseCounter"])
	end

	if cacheFlag == CacheFlag.CACHE_SPEED and player:HasCollectible(CollectibleType.INFINITE_VOID) then
		player.MoveSpeed = player.MoveSpeed + 0.3
	end

	if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(CollectibleType.INFINITE_VOID) then
		player.ShotSpeed = player.ShotSpeed + 0.2
	end

	--TODO add new image for birthright pickup
	if not ModData["BirthrightPickedUp"] and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		ModData["BirthrightPickedUp"] = true
		SFXManager():Play(SoundEffect.GOJO_BIRTHRIGHT)
		showAnimation("blackhole.png")
	end
end
GojoMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GojoMod.onCache)


function GojoMod:onRoomChange()
	if ModData["DomainActive"] then
		freezeAllEnemies()
	end
end
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GojoMod.onRoomChange)


function GojoMod:onLevelChange()
	ModData["DomainActive"] = false
end
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GojoMod.onLevelChange)


--TODO idk
---@param player EntityPlayer
function GojoMod:giveCostumeOnInit(player)
	local gojoType = Isaac.GetPlayerTypeByName("Gojo", false)

	if player:GetPlayerType() ~= gojoType then
		return
	end

	local hair = Isaac.GetCostumeIdByPath("gfx/characters/gojo_hair.anm2")

	player:AddNullCostume(hair)
end
GojoMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, GojoMod.giveCostumeOnInit)



---when the run starts or continues
---@param IsContinued boolean value is true when you continue a run, false when you start a new one
function GojoMod:onGameStart(IsContinued)
	ModData = DefaultData

	if IsContinued and GojoMod:HasData() then
		local data = json.decode(GojoMod:LoadData())

		for i, v in pairs(data) do
            ModData[tostring(i)] = data[i]
        end

	end
end
GojoMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GojoMod.onGameStart)


---when the game is closed normally
function GojoMod:onGameExit(_)
	GojoMod:SaveData(json.encode(ModData))
end
GojoMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GojoMod.onGameExit)