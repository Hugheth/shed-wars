local Teams = game:GetService("Teams")
local RequestChangeTeam =
	game.ReplicatedStorage:WaitForChild("RequestChangeTeam", 10) or
	error("Teams couldn't start because RequestChangeTeam is missing from ReplicatedStorage")

local TeamsServer = {}

function TeamsServer.setup()
	RequestChangeTeam.OnServerInvoke = function(player, teamName)
		player.Team = Teams:FindFirstChild(teamName)
	end
end

return TeamsServer
