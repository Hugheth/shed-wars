local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local ChoiceOverlay = require(game.ReplicatedStorage.ChoiceOverlay)
local RequestChangeTeam =
	game.ReplicatedStorage:WaitForChild("RequestChangeTeam", 10) or
	error("TeamsClient couldn't start because RequestChangeTeam is missing from ReplicatedStorage")

local TeamsClient = {}

local AUTOMATIC = "Automatic"

function TeamsClient.onChooseTeam(teamName)
	-- Add code here or replace the function to add your own behaviour for this event
end

function TeamsClient.showDialog()
	if TeamsClient.dialog then
		return
	end

	local choices = {
		{
			name = AUTOMATIC,
			color = Color3.fromRGB(255, 255, 255)
		}
	}

	for _, team in ipairs(Teams:GetChildren()) do
		table.insert(
			choices,
			{
				name = team.Name,
				color = team.TeamColor.Color
			}
		)
	end

	local dialog =
		ChoiceOverlay.open(
		{
			title = "Choose a team",
			choices = choices,
			buttonText = "Select team",
			onClose = TeamsClient.chooseTeam
		}
	)
	TeamsClient.dialog = dialog
end

function TeamsClient.chooseTeam(choice)
	local teamName = choice.name
	if teamName == AUTOMATIC then
		teamName = TeamsClient.autoAssignTeam()
	end

	RequestChangeTeam:InvokeServer(teamName)
	TeamsClient.teamName = teamName
	TeamsClient.onTeamChange(teamName)
end

function TeamsClient.autoAssignTeam()
	local teamCounts = {}
	for _, team in ipairs(Teams:GetChildren()) do
		teamCounts[team.Name] = 0
	end
	for _, player in ipairs(Players:GetChildren()) do
		if player.Team then
			teamCounts[player.Team.Name] = teamCounts[player.Team.Name] + 1
		end
	end

	local bestTeam
	for _, team in ipairs(Teams:GetChildren()) do
		if not bestTeam then
			bestTeam = team
		elseif teamCounts[team.Name] < teamCounts[bestTeam.Name] then
			bestTeam = team
		end
	end
	return bestTeam.Name
end

return TeamsClient
