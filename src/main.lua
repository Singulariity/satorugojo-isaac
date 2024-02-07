local json = require("json")

GojoMod = RegisterMod("Satoru Gojo", 1)

SoundEffect.DOMAIN_EXPANSION = Isaac.GetSoundIdByName("Domain Expansion")
SoundEffect.GOJO_BIRTHRIGHT = Isaac.GetSoundIdByName("Gojo Birthright")
SoundEffect.INFINITE_VOID = Isaac.GetSoundIdByName("Infinite Void")
CollectibleType.INFINITE_VOID = Isaac.GetItemIdByName("Infinite Void")
PlayerType.PLAYER_GOJO = Isaac.GetPlayerTypeByName("Gojo", false)
local GOJO_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/gojo_hair.anm2")
local lastFrame = nil

local function DefaultData()
	return {
		["DomainTrigger"] = -1, --domain trigger frame
		["DomainActive"] = 0, --domain active for next x rooms
		["UseCounter"] = 0, --infinite void use counter
		["BirthrightPickedUp"] = false, --is birthright item picked up
		["TransformationPickIDs"] = {} --table for storing picked up transformation item ids
	}
end

local ModData = DefaultData()

--called after the mod is completely ready/loaded
local function postLoad()
	GojoMod:updateEID()
end


--------------------------local functions start--------------------------

---@param image string
local function showAnimation(image)
	if GiantBookAPI then
		GiantBookAPI.playGiantBook("Appear", image, Color(0.2, 0/5, 1, 0), Color(0, 0, 0, 1), Color(0, 0, 0, 1))
	end
end

local function triggerDomain()
	ModData["DomainTrigger"] = 0
end

local function domainExpansion()
	while Game():IsPaused() do end
	local player = Isaac.GetPlayer()
	local roomEntities = Isaac.GetRoomEntities()
	for _, entity in ipairs(roomEntities) do
		if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
			if not entity:IsBoss() or ModData["UseCounter"] >= 5 then
				entity:AddFreeze(EntityRef(player), 100)
			end
		end
	end

	Game():ShakeScreen(30)
	SFXManager():Play(SoundEffect.INFINITE_VOID, 0.8)
end

local function hasValue(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

local function tableLength(tab)
	local count = 0
	for _ in pairs(tab) do count = count + 1 end
	return count
end

---@param player EntityPlayer?
local function giveCostume(player)
	if not player then
		player = Isaac.GetPlayer()
	end

	if player:GetPlayerType() == PlayerType.PLAYER_GOJO then
		player:TryRemoveNullCostume(GOJO_HAIR)
		player:AddNullCostume(GOJO_HAIR)
	end
end

local function onceHandler()
	if not lastFrame then
		lastFrame = 0
		return true
	end

	return false
end


--------------------------local functions end--------------------------


---used for transformation or other item pickup tracking
---@param player EntityPlayer
function GojoMod:pEffectUpdate(player)
	if player:HasCollectible(CollectibleType.INFINITE_VOID) and not hasValue(ModData["TransformationPickIDs"], CollectibleType.INFINITE_VOID) then
		table.insert(ModData["TransformationPickIDs"], CollectibleType.INFINITE_VOID)

		GojoMod:updateEID()
	end

	--TODO add new image for birthright pickup
	if not ModData["BirthrightPickedUp"] and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		ModData["BirthrightPickedUp"] = true
		SFXManager():Play(SoundEffect.GOJO_BIRTHRIGHT)
		showAnimation("blackhole.png")
	end

end
GojoMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, GojoMod.pEffectUpdate)


---@param collectibleID CollectibleType
---@param player EntityPlayer
function GojoMod:onUseInfiniteVoid(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	player:AnimateCollectible(collectibleID, "UseItem", "PlayerPickup")
	ModData["DomainActive"] = 2
	ModData["UseCounter"] = ModData["UseCounter"] + 1
	player:EvaluateItems()

	domainExpansion()

	SFXManager():Play(SoundEffect.DOMAIN_EXPANSION, 3)
	showAnimation("blackhole.png")
end
GojoMod:AddCallback(ModCallbacks.MC_USE_ITEM, GojoMod.onUseInfiniteVoid, CollectibleType.INFINITE_VOID)


---@param player EntityPlayer
---@param cacheFlag CacheFlag
function GojoMod:onCache(player, cacheFlag)
	if player == nil then return end

	if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(CollectibleType.INFINITE_VOID) then
		player.Damage = player.Damage + 0.5 + (0.2 * math.min(ModData["UseCounter"], 10))
	end

	if cacheFlag == CacheFlag.CACHE_SPEED and player:HasCollectible(CollectibleType.INFINITE_VOID) then
		player.MoveSpeed = player.MoveSpeed + 0.15
	end

	if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(CollectibleType.INFINITE_VOID) then
		player.ShotSpeed = player.ShotSpeed + 0.2
	end

end
GojoMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GojoMod.onCache)


function GojoMod:onRoomChange()
	if ModData["DomainActive"] > 0 and not Game():GetRoom():IsClear() then
		triggerDomain()
	end
end
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GojoMod.onRoomChange)


function GojoMod:onLevelChange()
	ModData["DomainActive"] = 0
	ModData["DomainTrigger"] = -1
end
GojoMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GojoMod.onLevelChange)


---EID item descriptions
function GojoMod:updateEID()
	if not EID then return end

	local transform_count = tableLength(ModData["TransformationPickIDs"])
	local transform_str = "{{Blank}} {{ColorTransform}} Sorcerer (" .. transform_count .. "/3)#"

	EID:addCollectible(CollectibleType.INFINITE_VOID, transform_str .. "↑ {{Damage}} +0.5 Damage#{{Blank}} {{Damage}} Bonus +0.2 per use (up to 10 times)#↑ {{Speed}} +0.15 Speed#↑ {{Shotspeed}} +0.2 Shot speed#When activated:#{{Blank}} {{Timer}} Vulnerable non-boss enemies will petrify for a moment when you enter a room for the next 2 rooms#{{Blank}} \7 Also petrifies bosses after 5 usages")
	--EID:addBirthright(PlayerType.PLAYER_GOJO, "{{TreasureRoomChanceSmall}} {{ColorSilver}}Throughout heaven and earth, I alone am the {{ColorRainbow}}Honored One{{ColorSilver}}.")
end


---@param player EntityPlayer
function GojoMod:giveCostumeOnInit(player)
	giveCostume(player)
end
GojoMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, GojoMod.giveCostumeOnInit)


function GojoMod:postUpdate()
	if ModData["DomainActive"] == 0 or ModData["DomainTrigger"] < 0 then return	end

	local start = ModData["DomainTrigger"]

	if start >= 10 then
		ModData["DomainTrigger"] = -1
		ModData["DomainActive"] = ModData["DomainActive"] - 1
		--local player = Isaac.GetPlayer()
		--player:AnimateHappy()
		domainExpansion()
	else
		ModData["DomainTrigger"] = ModData["DomainTrigger"] + 1
	end

	if lastFrame then
		if lastFrame < 5 then
			lastFrame = lastFrame + 1
		else
			lastFrame = nil
		end
	end

end
GojoMod:AddCallback(ModCallbacks.MC_POST_UPDATE, GojoMod.postUpdate)


---when the run starts or continues
---@param IsContinued boolean value is true when you continue a run, false when you start a new one
function GojoMod:onGameStart(IsContinued)

	--load saved/default data
	ModData = DefaultData()
	if IsContinued and GojoMod:HasData() then
		local data = json.decode(GojoMod:LoadData())

		for i, _ in pairs(data) do
			ModData[tostring(i)] = data[i]
		end
	end

	--give starting item to gojo
	if not IsContinued then
		local player = Isaac.GetPlayer()
		if player:GetPlayerType() == PlayerType.PLAYER_GOJO then
			player:AddCollectible(CollectibleType.INFINITE_VOID, 3, true)
		end
	end

	GojoMod:updateEID()
end
GojoMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GojoMod.onGameStart)


---when the game is closed normally
function GojoMod:onGameExit(_)
	GojoMod:SaveData(json.encode(ModData))
end
GojoMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GojoMod.onGameExit)

postLoad()