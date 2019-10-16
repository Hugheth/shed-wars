local Teams = game:GetService("Teams")
local RequestChangeTeam =
	game.ReplicatedStorage:WaitForChild("RequestChangeTeam", 10) or
	error("TeamManagerServer couldn't start because RequestChangeTeam is missing from ReplicatedStorage")

local TeamManagerServer = {}

RequestChangeTeam.OnServerInvoke = function(player, teamName)
	player.Team = Teams:FindFirstChild(teamName)
end

return TeamManagerServer
