local LobbyServer = require(game.ReplicatedStorage.LobbyServer)
local TeamsServer = require(game.ReplicatedStorage.TeamsServer)
local PlayerStats = require(game.ReplicatedStorage.PlayerStats)
local VitalsServer = require(game.ReplicatedStorage.VitalsServer)

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

LobbyServer.onReadyStatusChange = function(player, isReady)
	local nextStatus = isReady and "Ready" or "Not Ready"
	PlayerStats.setStat(player, "Status", nextStatus)
end
