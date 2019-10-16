local WelcomeMessage = require(game.ReplicatedStorage.WelcomeMessage)
local TeamsClient = require(game.ReplicatedStorage.TeamsClient)
local LobbyClient = require(game.ReplicatedStorage.LobbyClient)
local VitalsClient = require(game.ReplicatedStorage.VitalsClient)

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
