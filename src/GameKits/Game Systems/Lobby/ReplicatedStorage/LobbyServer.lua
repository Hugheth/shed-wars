--[[
	The purpose of this module is to provide examples of a game kit that:
	- Spans the client and the server
	- Maintains its own state which can be publicly queried
	- Officiates choices made on the client at the server interface
	- Provides event hooks that can be overwritten for user's own behaviour
]]
local RequestChangeReadyStatus =
	game.ReplicatedStorage:WaitForChild("RequestChangeReadyStatus", 10) or
	error("Teams couldn't start because RequestChangeReadyStatus is missing from ReplicatedStorage")
local LobbyStatus =
	game.ReplicatedStorage:WaitForChild("LobbyStatus", 10) or
	error("Teams couldn't start because LobbyStatus is missing from ReplicatedStorage")

local LobbyServer = {
	readyPlayers = {},
	countdownNumber = 0,
	inGame = false
}

function LobbyServer.onGameStart()
	-- Add code here or replace the function to add your own behaviour for this event
end

function LobbyServer.onGameEnd()
	-- Add code here or replace the function to add your own behaviour for this event
end

function LobbyServer.onJoin(player)
	LobbyServer.readyPlayers[player] = false
	LobbyServer.updateStatus()
end

function LobbyServer.onLeave(player)
	LobbyServer.readyPlayers[player] = nil
	LobbyServer.updateStatus()
end

function LobbyServer.setReadyStatus(player, isReady)
	if LobbyServer.inGame then
		return
	end
	LobbyServer.readyPlayers[player] = isReady
	LobbyServer.updateStatus()
	if LobbyServer.onReadyStatusChange then
		LobbyServer.onReadyStatusChange(player, isReady)
	end
end

function LobbyServer.startGame()
	LobbyStatus.Value = "InGame"
	LobbyServer.inGame = true
	local players = {}
	for player, isReady in pairs(LobbyServer.readyPlayers) do
		if isReady then
			table.insert(players, player)
		end
	end
	LobbyServer.inGamePlayers = players
	LobbyServer.onGameStart()
end

function LobbyServer.endGame()
	LobbyServer.inGame = false
	LobbyServer.onGameEnd()
	LobbyServer.unreadyPlayers()
end

function LobbyServer.unreadyPlayers()
	for _, player in ipairs(game.Players:GetChildren()) do
		LobbyServer.readyPlayers[player] = false
	end
	LobbyServer.updateStatus()
end

function LobbyServer.updateStatus()
	if LobbyServer.inGame then
		return
	end
	local playerCount = 0
	local allPlayersReady = true
	for player, status in pairs(LobbyServer.readyPlayers) do
		playerCount = playerCount + 1
		if status == false then
			allPlayersReady = false
		end
	end
	if playerCount < LobbyServer.minPlayers then
		LobbyStatus.Value = "Waiting for " .. (LobbyServer.minPlayers - playerCount) .. " more player(s)"
		LobbyServer.cancelCountdown()
	elseif allPlayersReady then
		LobbyServer.beginCountdown()
	else
		LobbyStatus.Value = "Waiting for all players to be ready"
		LobbyServer.cancelCountdown()
	end
end

function LobbyServer.beginCountdown()
	local countdownNumber = LobbyServer.countdownNumber
	spawn(
		function()
			for i = LobbyServer.readyTime, 1, -1 do
				LobbyStatus.Value = "Starting in " .. i
				wait(1)
				if countdownNumber ~= LobbyServer.countdownNumber then
					return
				end
			end
			LobbyServer.startGame()
		end
	)
end

function LobbyServer.cancelCountdown()
	LobbyServer.countdownNumber = LobbyServer.countdownNumber + 1
end

function LobbyServer.setup(options)
	assert(type(options.minPlayers) == "number", "minPlayers must be a number")
	assert(type(options.readyTime) == "number", "readyTime must be a number")

	LobbyServer.minPlayers = options.minPlayers
	LobbyServer.readyTime = options.readyTime

	game.Players.PlayerAdded:Connect(LobbyServer.onJoin)
	game.Players.PlayerRemoving:Connect(LobbyServer.onLeave)
	RequestChangeReadyStatus.OnServerInvoke = LobbyServer.setReadyStatus
	LobbyServer.updateStatus()
end

return LobbyServer
