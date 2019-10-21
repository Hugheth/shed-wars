local MessageOverlay = require(game.ReplicatedStorage.MessageOverlay)
local TeamsClient = require(game.ReplicatedStorage.TeamsClient)
local LobbyClient = require(game.ReplicatedStorage.LobbyClient)
local VitalsClient = require(game.ReplicatedStorage.VitalsClient)
local PlayerRaycaster = require(game.ReplicatedStorage.PlayerRaycaster)
local SpectatorModeClient = require(game.ReplicatedStorage.SpectatorModeClient)
local PlayerSpawnClient = require(game.ReplicatedStorage.PlayerSpawnClient)
local OverShoulderCamera = require(game.ReplicatedStorage.OverShoulderCamera)
local LoadoutsClient = require(game.ReplicatedStorage.LoadoutsClient)
local MiningClient = require(game.ReplicatedStorage.MiningClient)
local findParts = require(game.ReplicatedStorage.FindParts)

SpectatorModeClient.setup()

local buildings = game.Workspace:WaitForChild("Buildings", 10)
local LightManager = require(game.ReplicatedStorage.LightManager)
local lights = LightManager.findLights(buildings)
LightManager.pulsate(lights)
TeamsClient.showDialog()

TeamsClient.onTeamChange = function(teamName)
	local messages
	if teamName == "Red Ranchers" then
		messages = {
			"You joined Red! The blues will feel the fury of your axe!",
			"You joined Red! Grab your axe Red, you'll need it!",
			"You joined Red! Feeling lucky today hey Red?"
		}
	else
		messages = {
			"You joined Blue! The reds will feel the fury of your axe!",
			"You joined Blue! Grab your axe Blue, you'll need it!",
			"You joined Blue! Feeling lucky today hey Blue?"
		}
	end
	local dialog = MessageOverlay.open("Shed Wars", messages[math.random(1, #messages)])
	dialog.onClose = function()
		if LobbyClient.inGame then
			MessageOverlay.show({"You are currently spectating!"})
		else
			LobbyClient.showDialog()
		end
	end
end

LobbyClient.onGameStart = function(playerInGame)
	OverShoulderCamera.start()
end

LobbyClient.setup()
VitalsClient.setup({"Life", "Wood", "Metal"})
PlayerRaycaster.setup(50)

local function getSpawnModels()
	local isRedTeam = TeamsClient.teamName == "Red Ranchers"
	local shedName = isRedTeam and "RedShed" or "BlueShed"
	local sheds = findParts(game.Workspace, shedName)
	local spawns = findParts(sheds, "SpawnPlace")
	return spawns
end

PlayerSpawnClient.setup(getSpawnModels)

PlayerSpawnClient.onSpawnChange = function()
	LoadoutsClient.showDialog()
	LoadoutsClient.showOnRespawn()
end

local function getMineParts()
	return findParts(game.Workspace, "Wood")
end

MiningClient.setup(getMineParts)

function LoadoutsClient.onShowDialog()
	OverShoulderCamera.stop()
end

function LoadoutsClient.onLoadoutChange()
	OverShoulderCamera.start()
	MiningClient.start()
end
