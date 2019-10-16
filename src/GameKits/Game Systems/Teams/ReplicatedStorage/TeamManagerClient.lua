local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local TeamDialog =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("TeamDialog", 10) or
	error("TeamManager couldn't start because TeamDialog is missing from StarterGui")
local RequestChangeTeam =
	game.ReplicatedStorage:WaitForChild("RequestChangeTeam", 10) or
	error("TeamManager couldn't start because RequestChangeTeam is missing from ReplicatedStorage")

local TeamManager = {}

local AUTOMATIC = "Automatic"
local SPACING = 10
local PADDING = 20

function TeamManager.showDialog()
	local contents = TeamDialog.Frame.ContentFrame
	local label = contents.TeamButton
	label.Visible = false

	local function deselectLabels()
		contents[AUTOMATIC].BackgroundTransparency = 1
		for _, team in ipairs(Teams:GetChildren()) do
			contents[team.Name].BackgroundTransparency = 1
		end
	end

	local function onClick(teamName)
		TeamManager.selectedTeam = teamName
		deselectLabels()
		contents[teamName].BackgroundTransparency = 0
	end

	local function drawLabel(index, teamName, teamColor)
		local teamLabel = label:Clone()
		teamLabel.Name = teamName
		teamLabel.Text = teamName
		teamLabel.Visible = true
		teamLabel.TextColor3 = teamColor
		teamLabel.Position = UDim2.new(0, PADDING, 0, index * (label.Size.Y.Offset + SPACING) + PADDING)
		teamLabel.MouseButton1Click:Connect(
			function()
				onClick(teamName)
			end
		)
		teamLabel.Parent = contents
	end

	drawLabel(0, AUTOMATIC, Color3.fromRGB(255, 255, 255))
	for index, team in ipairs(Teams:GetChildren()) do
		drawLabel(index, team.Name, team.TeamColor.Color)
	end

	deselectLabels()

	local size = (#Teams:GetChildren() + 1) * (label.Size.Y.Offset + SPACING) + 2 * PADDING
	contents.CanvasSize = UDim2.new(0, 0, 0, size)
	TeamDialog.Enabled = true
end

function TeamManager.hideDialog()
	TeamDialog.Enabled = false
	local contents = TeamDialog.Frame.ContentFrame
	contents[AUTOMATIC]:Destroy()
	for _, team in ipairs(Teams:GetChildren()) do
		contents[team.Name]:Destroy()
	end
end

function TeamManager.chooseTeam()
	local teamName = TeamManager.selectedTeam

	if teamName == AUTOMATIC then
		teamName = TeamManager.autoAssignTeam()
	end

	RequestChangeTeam:InvokeServer(teamName)

	if TeamManager.onChangeTeam then
		TeamManager.onChangeTeam(teamName)
	end
end

function TeamManager.autoAssignTeam()
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

local function handleClose()
	TeamManager.hideDialog()
	TeamManager.chooseTeam()
	if TeamManager.onClose then
		TeamManager.onClose()
	end
end
TeamDialog.Frame.JoinButton.MouseButton1Click:Connect(handleClose)

return TeamManager
