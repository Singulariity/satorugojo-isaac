local ENUMS = {}

ENUMS.PLAYERS = {
	GOJO = Isaac.GetPlayerTypeByName("Gojo", false)
}

ENUMS.SOUNDS = {
	DOMAIN_EXPANSION = Isaac.GetSoundIdByName("Domain Expansion"),
	GOJO_BIRTHRIGHT = Isaac.GetSoundIdByName("Gojo Birthright"),
	INFINITE_VOID = Isaac.GetSoundIdByName("Infinite Void")
}

ENUMS.ITEMS = {
	INFINITE_VOID = Isaac.GetItemIdByName("Infinite Void")
}

ENUMS.COSTUMES = {
	GOJO_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/gojo_hair.anm2")
}

return ENUMS