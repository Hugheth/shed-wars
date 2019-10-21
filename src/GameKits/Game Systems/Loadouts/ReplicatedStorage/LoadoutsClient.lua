--[[
	The purpose of this module is to provide examples of a game kit that:
	- Spans the client and the server
	- Uses other game kits to display common UI
	- Allows the user to enhance the game kit with optional functionality (showOnRespawn)
]]
local ChoiceOverlay = require(game.ReplicatedStorage.ChoiceOverlay)
local Loadouts =
	game.ReplicatedStorage:WaitForChild("Loadouts", 10) or
	error("LoadoutsClient couldn't start because Loadouts is missing from ReplicatedStorage")
local RequestChangeLoadout =
	game.ReplicatedStorage:WaitForChild("RequestChangeLoadout", 10) or
	error("LoadoutsClient couldn't start because RequestChangeLoadout is missing from ReplicatedStorage")

local LoadoutsClient = {}

function LoadoutsClient.onShowDialog()
	-- Add code here or replace the function to add your own behaviour for this event
end

function LoadoutsClient.onLoadoutChange()
	-- Add code here or replace the function to add your own behaviour for this event
end

function LoadoutsClient.showDialog()
	if LoadoutsClient.dialog then
		return
	end

	local choices = {}
	for _, loadout in ipairs(Loadouts:GetChildren()) do
		if loadout:IsA("Folder") and loadout.Name ~= "All" then
			table.insert(
				choices,
				{
					name = loadout.Name,
					color = Color3.fromRGB(255, 255, 255)
				}
			)
		end
	end

	local dialog =
		ChoiceOverlay.open(
		{
			title = "Choose a class",
			choices = choices,
			buttonText = "Select class",
			onClose = LoadoutsClient.chooseLoadout
		}
	)
	LoadoutsClient.dialog = dialog
	LoadoutsClient.onShowDialog()
end

function LoadoutsClient.chooseLoadout(choice)
	RequestChangeLoadout:InvokeServer(choice.name)
	LoadoutsClient.onLoadoutChange()
end

function LoadoutsClient.showOnRespawn()
	game.Players.LocalPlayer.CharacterRemoving:Connect(
		function()
			LoadoutsClient.showDialog()
		end
	)
end

return LoadoutsClient
