local ENUMS = {}

---@param name string player name from `players.xml`
---@param tainted boolean
local function Character(name, tainted)
	local table = {}

	table.Name = name
	table.ID = Isaac.GetPlayerTypeByName(name, tainted)

	return table
end

---@param id PlayerType
function ENUMS:getPlayerById(id)
	for i, _ in pairs(ENUMS.PLAYERS) do
		if ENUMS.PLAYERS[i].ID == id then
			return ENUMS.PLAYERS[i]
		end
	end
	return nil
end

---@param name string item name from `items.xml`
---@param character GojoPlayer Item belongs to
---@param completion Completion unlock after completion.
---@param hard boolean is hard mode completion
---@param achievement string achievement image
local function Item(name, character, completion, hard, achievement)
	local table = {}

	table.Name = name
	table.ID = Isaac.GetItemIdByName(name)
	table.Character = character
	table.Completion = completion
	table.Hard = hard
	table.Achievement = achievement

	return table
end

---This item will be unlocked by default
---@param name string item name from `items.xml`
local function DefaultItem(name)
	---@diagnostic disable-next-line: param-type-mismatch
	return Item(name, nil, nil, nil, nil)
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

---@enum Completion
ENUMS.COMPLETION = {
	MomsHeart = "MomsHeart",
	Isaac = "Isaac",
	Satan = "Satan",
	BlueBaby = "BlueBaby",
	Lamb = "Lamb",
	BossRush = "BossRush",
	Hush = "Hush",
	MegaSatan = "MegaSatan",
	Delirium = "Delirium",
	Mother = "Mother",
	Beast = "Beast",
	GreedMode = "GreedMode",
	FullCompletion = "FullCompletion"
}

---@enum GojoPlayer
ENUMS.PLAYERS = {
	GOJO = Character("Gojo", false)
}

ENUMS.SOUNDS = {
	DOMAIN_EXPANSION = Isaac.GetSoundIdByName("Domain Expansion"),
	GOJO_BIRTHRIGHT = Isaac.GetSoundIdByName("Gojo Birthright"),
	INFINITE_VOID = Isaac.GetSoundIdByName("Infinite Void"),
	CURSED_HEART_COLLECT = Isaac.GetSoundIdByName("Cursed Heart Collect")
}

ENUMS.ITEMS = {
	INFINITE_VOID = Item("Infinite Void", ENUMS.PLAYERS.GOJO, ENUMS.COMPLETION.Delirium, false, "achievement_infinite_void.png"),
	LIMIT = Item("Limit", ENUMS.PLAYERS.GOJO, ENUMS.COMPLETION.MomsHeart, false, "achievement_limit.png"),
	INVERTED_SPEAR_OF_HEAVEN = Item("Inverted Spear of Heaven", ENUMS.PLAYERS.GOJO, ENUMS.COMPLETION.Isaac, false, "achievement_inverted_spear_of_heaven.png"),
	SUKUNA_FINGER = DefaultItem("Sukuna's Finger"),
	--SUKUNA_FINGER = Item("Sukuna's Finger", ENUMS.PLAYERS.GOJO, ENUMS.COMPLETION.Satan, false, "achievement_sukuna_finger.png")
}

ENUMS.ENTITY = {
	CURSED_HEART = {
		ENTITY_TYPE = Isaac.GetEntityTypeByName("Cursed Heart"),
		VARIANT = Isaac.GetEntityVariantByName("Cursed Heart"),
		SUBTYPE = 107
	},
	CURSED_HEART_HALF = {
		ENTITY_TYPE = Isaac.GetEntityTypeByName("Cursed Heart (half)"),
		VARIANT = Isaac.GetEntityVariantByName("Cursed Heart (half)"),
		SUBTYPE = 108
	},
	CURSED_DEAL = {
		ENTITY_TYPE = Isaac.GetEntityTypeByName("Cursed Deal"),
		VARIANT = Isaac.GetEntityVariantByName("Cursed Deal"),
	}
}

ENUMS.COSTUMES = {
	GOJO_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/gojo_hair.anm2"),
	GOJO_BODY = Isaac.GetCostumeIdByPath("gfx/characters/gojo_body.anm2")
}

return ENUMS