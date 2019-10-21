--[[
	The purpose of this module is to provide examples of a game kit that:
	- Spans the client and the server
	- Officiates choices made on the client at the server interface
]]
local Loadouts =
	game.ReplicatedStorage:WaitForChild("Loadouts", 10) or
	error("Loadouts couldn't start because Loadout is missing from ReplicatedStorage")
local RequestChangeLoadout =
	game.ReplicatedStorage:WaitForChild("RequestChangeLoadout", 10) or
	error("Loadouts couldn't start because RequestChangeLoadout is missing from ReplicatedStorage")

local LoadoutsServer = {}

function LoadoutsServer.changeLoadout(player, loadoutName)
	player.Backpack:ClearAllChildren()
	for _, template in ipairs(Loadouts.All:GetChildren()) do
		local item = template:Clone()
		item.Parent = player.Backpack
	end
	for _, template in ipairs(Loadouts[loadoutName]:GetChildren()) do
		local item = template:Clone()
		item.Parent = player.Backpack
	end
end

function LoadoutsServer.setup()
	RequestChangeLoadout.OnServerInvoke = LoadoutsServer.changeLoadout
end

return LoadoutsServer
