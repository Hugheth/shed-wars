local WelcomeMessage = require(game.ReplicatedStorage.WelcomeMessage)
local TeamsClient = require(game.ReplicatedStorage.TeamsClient)
local LobbyClient = require(game.ReplicatedStorage.LobbyClient)
local VitalsClient = require(game.ReplicatedStorage.VitalsClient)
local PlayerRaycaster = require(game.ReplicatedStorage.PlayerRaycaster)

TeamsClient.showDialog()

TeamsClient.onTeamChange = function(teamName)
	if teamName == "Red Ranchers" then
		WelcomeMessage.show(
			{
				"You joined Red! The greens will feel the fury of your axe!",
				"You joined Red! Grab your axe Red, you'll need it!",
				"You joined Red! Feeling lucky today hey Red?"
			}
		)
	else
		WelcomeMessage.show(
			{
				"You joined Green! The reds will feel the fury of your axe!",
				"You joined Green! Grab your axe Green, you'll need it!",
				"You joined Green! Feeling lucky today hey Green?"
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

LobbyClient.setup()
VitalsClient.setup({"Life", "Wood", "Metal"})

PlayerRaycaster.setup(50)
local spawnParts = PlayerRaycaster.findParts(game.Workspace, "SpawnPlace")
print("Found spawns", #spawnParts)

local function onHoverSpawn(part, position)
	print("Hover over!", part, position)
end
local function onLeaveSpawn(part, position)
	print("Leave spawn!", part, position)
end
PlayerRaycaster.connectParts(spawnParts, onHoverSpawn, onLeaveSpawn)