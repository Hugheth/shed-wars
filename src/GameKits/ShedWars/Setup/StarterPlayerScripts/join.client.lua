local WelcomeMessage = require(game.ReplicatedStorage.WelcomeMessage)
local TeamManagerClient = require(game.ReplicatedStorage.TeamManagerClient)

TeamManagerClient.showDialog()

TeamManagerClient.onChangeTeam = function(teamName)
	if teamName == "Red Ranchers" then
		WelcomeMessage.show(
			{
				"You joined Red! The greens will feel the fury of my axe!",
				"You joined Red! Grab your axe Red, you'll need it!",
				"You joined Red! Feeling lucky today hey Red?"
			}
		)
	else
		WelcomeMessage.show(
			{
				"You joined Green! The reds will feel the fury of my axe!",
				"You joined Green! Grab your axe Green, you'll need it!",
				"You joined Green! Feeling lucky today hey Green?"
			}
		)
	end
end

WelcomeMessage.onClose = function()
end
