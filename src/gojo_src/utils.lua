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

---@param image string
function Utils:showAnimation(image)
	if not GiantBookAPI then return end

	GiantBookAPI.playGiantBook("Appear", image, Color(0.2, 0/5, 1, 0), Color(0, 0, 0, 1), Color(0, 0, 0, 1))
end

return Utils