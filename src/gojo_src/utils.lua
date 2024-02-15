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

	GiantBookAPI.playGiantBook("Shake", image, Color(0.2, 0/5, 1, 0), Color(0, 0, 0, 1), Color(0, 0, 0, 1))
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

return Utils