local json = require("json")

local function DefaultData()
	return {
		DomainTrigger = -1, --domain trigger frame
		DomainActive = 0, --domain active for next x rooms
		UseCounter = 0, --infinite void use counter
		Birthright = false, --is birthright item picked up
		TransformationPickIDs = {} --table for storing picked up transformation item ids
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

	if continue and Isaac.HasModData(modRef) then
		_data = json.decode(modRef:LoadData())
	else
		_data = DefaultData()
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