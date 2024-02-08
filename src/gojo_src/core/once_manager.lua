local Utils = require("gojo_src.utils")

local OnceManager = {}

local onceData = {}

---Sets cooldown for a key string. Useful for functions that runs more than once at the same time.
---@param key string
---@param frames integer? cooldown frames. `default: 5`
function OnceManager:useOnce(key, frames)
	if not onceData[key] then
		onceData[key] = frames or 5
		return true
	end

	return false
end

function OnceManager.postUpdate()
	if Utils:tableLength(onceData) > 0 then
		for i, _ in pairs(onceData) do
			if onceData[tostring(i)] > 0 then
				onceData[tostring(i)] = onceData[i] - 1
			else
				onceData[tostring(i)] = nil
			end
		end
	end
end

return OnceManager