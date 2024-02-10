local ENUMS = {}

---@param name string item name from `items.xml`
---@param achievement string achievement image
---@param unlockBoss EntityType unlocks the item after defeating this boss
---@param unlockedByDefault boolean? is the item unlocked by default? default: `false`
local function Item(name, achievement, unlockBoss, unlockedByDefault)
	local table = {}

	table.Name = name
	table.ID = Isaac.GetItemIdByName(name)
	table.Achievement = achievement
	table.UnlockBoss = unlockBoss
	table.UnlockedDefault = unlockedByDefault

	return table
end

---@param name string
function ENUMS:getItemByName(name)
	for i, _ in pairs(ENUMS.ITEMS) do
		if ENUMS.ITEMS[i].Name == name then
			return ENUMS.ITEMS[i]
		end
	end
	return nil
end

---@param id CollectibleType
function ENUMS:getItemById(id)
	for i, _ in pairs(ENUMS.ITEMS) do
		if ENUMS.ITEMS[i].ID == id then
			return ENUMS.ITEMS[i]
		end
	end
	return nil
end

ENUMS.PLAYERS = {
	GOJO = Isaac.GetPlayerTypeByName("Gojo", false)
}

ENUMS.SOUNDS = {
	DOMAIN_EXPANSION = Isaac.GetSoundIdByName("Domain Expansion"),
	GOJO_BIRTHRIGHT = Isaac.GetSoundIdByName("Gojo Birthright"),
	INFINITE_VOID = Isaac.GetSoundIdByName("Infinite Void")
}

--fix remove defaults
ENUMS.ITEMS = {
	INFINITE_VOID = Item("Infinite Void", "achievement_infinite_void.png", EntityType.ENTITY_DELIRIUM, true),
	LIMIT = Item("Limit", "achievement_limit.png", EntityType.ENTITY_MOMS_HEART, true)
}

ENUMS.COSTUMES = {
	GOJO_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/gojo_hair.anm2")
}

return ENUMS