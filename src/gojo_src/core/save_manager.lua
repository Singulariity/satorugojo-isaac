local json = require("json")
local Utils = require("gojo_src.utils")

local function DefaultData()
	return {
		DomainTrigger = -1, --domain trigger frame
		DomainActive = 0, --domain active for next x rooms
		UseCounter = 0, --infinite void use counter
		Birthright = false, --is birthright item picked up
		TransformationPickIDs = {}, --table for storing picked up transformation item ids
		--permanent data does not reset with each run
		PermanentData = {
			Unlocks = {}
		}
	}
end

local SaveManager = {}
local Data = DefaultData()
local modRef

local function saveData()
	modRef:SaveData(json.encode(Data))
end

function SaveManager.Init(mod)
	modRef = mod
end

---@param player EntityPlayer
function SaveManager.postPlayerInit(player)
	local continue = Game():GetFrameCount() ~= 0
	local _data

	if Isaac.HasModData(modRef) then
		local saved_data = json.decode(modRef:LoadData())

		if continue then
			_data = saved_data
		else
			_data = Utils:copyTable(DefaultData())

			for i, _ in pairs(saved_data.PermanentData) do
				_data.PermanentData[tostring(i)] = saved_data.PermanentData[i]
			end
		end
	else
		_data = Utils:copyTable(DefaultData())
	end

	for i, _ in pairs(_data) do
		Data[tostring(i)] = _data[i]
	end
end

function SaveManager.postNewLevel()
	saveData()
end

function SaveManager.preGameExit()
	saveData()
end

return {
	SaveManager = SaveManager,
	Data = Data
}