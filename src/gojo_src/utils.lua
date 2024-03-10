local Utils = {}

---@param tab table
---@return boolean
function Utils:hasValue(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

---@param tab table
---@return integer
function Utils:tableLength(tab)
	local count = 0
	for _ in pairs(tab) do count = count + 1 end
	return count
end

---image should be in `gfx/ui/giantbook/` folder
---@param image string
function Utils:showAnimation(image)
	if not GiantBookAPI then return end

	GiantBookAPI.playGiantBook("Appear", image, Color(0.2, 0/5, 1, 0), Color(0, 0, 0, 1), Color(0, 0, 0, 1))
end

---image should be in `gfx/ui/achievements/` folder
---@param image string
function Utils:ShowAchievement(image)
	if not GiantBookAPI then return end

	GiantBookAPI.ShowAchievement(image)
end

---@param tab table
function Utils:copyTable(tab)
	local newTable = {}

	for i, _ in pairs(tab) do
		local value
		if type(tab[i]) == "table" then
			value = Utils:copyTable(tab[i])
		else
			value = tab[i]
		end
		newTable[tostring(i)] = value
	end

	return newTable
end

---adds second table into first table
---@param first table
---@param second table
function Utils:mergeTables(first, second)
	for k,v in pairs(second) do
		if type(v) == "table" then
			if type(first[k] or false) == "table" then
				Utils:mergeTables(first[k] or {}, second[k] or {})
			else
				first[k] = v
			end
		else
			first[k] = v
		end
	end
	return first
end

function Utils:getScreenSize()
	local room = Game():GetRoom()
	local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)

	return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

function Utils:getHUDOffset()
	local hud_offset = math.floor(Options.HUDOffset * 10^2 + 0.5) / 10^2

	return Vector(hud_offset * 20, hud_offset * 12)
end

local baseDmgMultipliers = {
	[tostring(PlayerType.PLAYER_EVE)] = 0.75,
	[tostring(PlayerType.PLAYER_MAGDALENE)] = 0.75,
	[tostring(PlayerType.PLAYER_BLUEBABY)] = 1.05,
	[tostring(PlayerType.PLAYER_KEEPER)] = 1.20,
	[tostring(PlayerType.PLAYER_CAIN)] = 1.20,
	[tostring(PlayerType.PLAYER_CAIN_B)] = 1.20,
	[tostring(PlayerType.PLAYER_EVE_B)] = 1.20,
	[tostring(PlayerType.PLAYER_JUDAS)] = 1.35,
	[tostring(PlayerType.PLAYER_AZAZEL)] = 1.50,
	[tostring(PlayerType.PLAYER_THEFORGOTTEN)] = 1.50,
	[tostring(PlayerType.PLAYER_AZAZEL_B)] = 1.50,
	[tostring(PlayerType.PLAYER_THEFORGOTTEN_B)] = 1.50,
	[tostring(PlayerType.PLAYER_LAZARUS2_B)] = 1.50,
	[tostring(PlayerType.PLAYER_LAZARUS2)] = 1.40,
	[tostring(PlayerType.PLAYER_THELOST_B)] = 1.30,
	[tostring(PlayerType.PLAYER_BLACKJUDAS)] = 2.00,
}

---not perfect but i think this is ok
---@param player EntityPlayer
function Utils:getPlayerDamageMultiplier(player)
	local playerType = player:GetPlayerType()
	local baseMul = baseDmgMultipliers[tostring(playerType)] or 1
	local bonusMul = 1

	if playerType == PlayerType.PLAYER_EVE then
		if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then
			baseMul = baseMul + 0.25
		end
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART) then
		bonusMul = bonusMul * 2.3
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA) then
		bonusMul = bonusMul * 2.0
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
		bonusMul = bonusMul * 2.0
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD) then
		bonusMul = bonusMul * 1.5
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) then
		bonusMul = bonusMul * 1.5
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_IMMACULATE_HEART) then
		bonusMul = bonusMul * 1.2
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN) then
		bonusMul = bonusMul * 0.9
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
		bonusMul = bonusMul * 0.8
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
		bonusMul = bonusMul * 0.3
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
		bonusMul = bonusMul * 0.2
	end

	return baseMul * bonusMul
end

return Utils