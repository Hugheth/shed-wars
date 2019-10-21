--[[
	The purpose of this script is to provide examples of a script that:
	- Is attached to objects in the workspace
	- Uses a game kit module to add behaviour to the object
]]
local MiningClient = require(game.ReplicatedStorage.MiningClient)

local function onActivation()
	print("Connect activation!")
	MiningClient.mine()
end

script.Parent.Activated:Connect(onActivation)
