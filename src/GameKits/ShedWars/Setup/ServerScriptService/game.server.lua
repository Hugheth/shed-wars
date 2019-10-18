local LobbyServer = require(game.ReplicatedStorage.LobbyServer)
local TeamsServer = require(game.ReplicatedStorage.TeamsServer)
local PlayerStats = require(game.ReplicatedStorage.PlayerStats)
local PlayerSpawnServer = require(game.ReplicatedStorage.PlayerSpawnServer)
local LoadoutsServer = require(game.ReplicatedStorage.LoadoutsServer)
local VitalsServer = require(game.ReplicatedStorage.VitalsServer)
local SpectatorModeServer = require(game.ReplicatedStorage.SpectatorModeServer)

LobbyServer.setup(
	{
		minPlayers = 1,
		readyTime = 4
	}
)
TeamsServer.setup()
PlayerStats.setup(
	{"Status", "Deaths"},
	{
		Status = "Not Ready",
		Deaths = 0
	}
)
VitalsServer.setup(
	{"Life", "Wood", "Metal"},
	{
		Life = 100,
		Wood = 0,
		Metal = 0
	}
)
PlayerSpawnServer.setup()
SpectatorModeServer.setup()
LoadoutsServer.setup()

LobbyServer.onReadyStatusChange = function(player, isReady)
	local nextStatus = isReady and "Ready" or "Not Ready"
	PlayerStats.setStat(player, "Status", nextStatus)
end

LobbyServer.onGameStart = function()
	for _, player in ipairs(LobbyServer.inGamePlayers) do
		PlayerStats.setStat(player, "Status", "Spawning")
		PlayerSpawnServer.activate(player)
	end
end

PlayerSpawnServer.onSpawnChange = function(player, spawnLocation, spawnModel)
	PlayerStats.setStat(player, "Status", "Alive")
	PlayerSpawnServer.deactivate(player)
	SpectatorModeServer.deactivate(player)
	local playerPosition = spawnLocation.Position + Vector3.new(0, 3, 0)
	player.Character:SetPrimaryPartCFrame(CFrame.new(playerPosition))
	local base = spawnModel:Clone()
	base.Name = "Base"
	for _, part in ipairs(base:GetChildren()) do
		part.Transparency = 1
	end
	base.Parent = spawnModel.Parent
end

game.Players.PlayerAdded:Connect(
	function(player)
		local character = player.Character or player.CharacterAdded:Wait()
		spawn(
			function()
				character:SetPrimaryPartCFrame(CFrame.new(240, 60, 180))
			end
		)
		SpectatorModeServer.activate(player)

		player.CharacterAdded:Connect(
			function(character)
				PlayerStats.setStat(player, "Status", "Alive")
			end
		)
		player.CharacterRemoving:Connect(
			function(character)
				PlayerStats.setStat(player, "Status", "Dead")
				PlayerStats.setStat(player, "Deaths", PlayerStats.getStat(player, "Deaths") + 1)
			end
		)
	end
)
