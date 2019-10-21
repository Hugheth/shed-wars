--[[
	The purpose of this module is to provide examples of a game kit that:
	- Spans the client and the server
	- Maintains its own state which can be publicly queried
	- Provides state in the data model that can be listened to on the client
	- Officiates choices made on the client at the server interface
	- Provides event hooks that can be overwritten for user's own behaviour
]]
local RequestChangeSpawn =
	game.ReplicatedStorage:WaitForChild("RequestChangeSpawn", 10) or
	error("PlayerSpawnServer couldn't start because RequestChangeSpawn is missing from ReplicatedStorage")

local PlayerSpawnServer = {
	spawnLocations = {}
}

function PlayerSpawnServer.onSpawnChange(player, spawnLocation)
	-- Add code here or replace the function to add your own behaviour for this event
end

function PlayerSpawnServer.onJoin(player)
	local isSpawning = Instance.new("BoolValue")
	isSpawning.Name = "IsSpawning"
	isSpawning.Value = false
	isSpawning.Parent = player
end

function PlayerSpawnServer.onLeave(player)
	PlayerSpawnServer.spawnLocations[player] = nil
end

function PlayerSpawnServer.activate(player)
	player:WaitForChild("IsSpawning").Value = true
end

function PlayerSpawnServer.deactivate(player)
	player:WaitForChild("IsSpawning").Value = false
end

function PlayerSpawnServer.changeSpawn(player, spawnModel)
	local spawnLocation = PlayerSpawnServer.spawnLocations[player]
	if not spawnLocation then
		spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Transparency = 1
		spawnLocation.Parent = game.Workspace
		player.RespawnLocation = spawnLocation
		PlayerSpawnServer.spawnLocations[player] = spawnLocation
	end
	spawnLocation.Position = spawnModel.PrimaryPart.Position
	spawnLocation.Size = spawnModel.PrimaryPart.Size
	PlayerSpawnServer.onSpawnChange(player, spawnLocation, spawnModel)
end

function PlayerSpawnServer.setup()
	game.Players.PlayerAdded:Connect(PlayerSpawnServer.onJoin)
	game.Players.PlayerRemoving:Connect(PlayerSpawnServer.onLeave)
	RequestChangeSpawn.OnServerInvoke = PlayerSpawnServer.changeSpawn
end

return PlayerSpawnServer
