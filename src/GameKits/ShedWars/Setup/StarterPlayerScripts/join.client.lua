local WelcomeMessage = require(game.ReplicatedStorage.WelcomeMessage)
local TeamsClient = require(game.ReplicatedStorage.TeamsClient)
local LobbyClient = require(game.ReplicatedStorage.LobbyClient)
local VitalsClient = require(game.ReplicatedStorage.VitalsClient)
local PlayerRaycaster = require(game.ReplicatedStorage.PlayerRaycaster)
local SpectatorModeClient = require(game.ReplicatedStorage.SpectatorModeClient)
local OverShoulderCamera = require(game.ReplicatedStorage.OverShoulderCamera)

SpectatorModeClient.setup()

local buildings = game.Workspace:WaitForChild("Buildings", 1000)
local LightManager = require(game.ReplicatedStorage.LightManager)
local lights = LightManager.findLights(buildings)
LightManager.pulsate(lights)
TeamsClient.showDialog()

TeamsClient.onClose = function(teamName)
	if teamName == "Red Ranchers" then
		WelcomeMessage.show(
			{
				"You joined Red! The blues will feel the fury of your axe!",
				"You joined Red! Grab your axe Red, you'll need it!",
				"You joined Red! Feeling lucky today hey Red?"
			}
		)
	else
		WelcomeMessage.show(
			{
				"You joined Blue! The reds will feel the fury of your axe!",
				"You joined Blue! Grab your axe Blue, you'll need it!",
				"You joined Blue! Feeling lucky today hey Blue?"
			}
		)
	end
end

WelcomeMessage.onClose = function()
	if LobbyClient.inGame then
		WelcomeMessage.show({"You are currently spectating!"})
	else
		LobbyClient.showDialog()
	end
end

local function focusSpawn(part)
	part.Color = Color3.fromRGB(255, 255, 255)
	part.Size = Vector3.new(20, 5, 20)
	part.Transparency = 0
end
local function blurSpawn(part)
	part.Color = Color3.fromRGB(255, 255, 255)
	part.Size = Vector3.new(20, 5, 20)
	part.Transparency = 0.5
end

LobbyClient.onGameStart = function(playerInGame)
	local isRedTeam = TeamsClient.teamName == "Red Ranchers"
	local shedName = isRedTeam and "RedShed" or "BlueShed"
	local sheds = PlayerRaycaster.findParts(game.Workspace, shedName)
	local spawns = PlayerRaycaster.findParts(sheds, "SpawnPlace")

	for _, spawn in ipairs(spawns) do
		blurSpawn(spawn)
	end

	PlayerRaycaster.connectParts(spawns, focusSpawn, blurSpawn)

	OverShoulderCamera.start()
end

LobbyClient.setup()
VitalsClient.setup({"Life", "Wood", "Metal"})
PlayerRaycaster.setup(50)
