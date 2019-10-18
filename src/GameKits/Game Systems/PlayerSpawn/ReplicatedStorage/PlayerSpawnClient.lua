local UserInputService = game:GetService("UserInputService")
local PlayerRaycaster = require(game.ReplicatedStorage.PlayerRaycaster)
local findParts = require(game.ReplicatedStorage.FindParts)
local SpawnOverlay =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("SpawnOverlay", 10) or
	error("MessageOverlay couldn't start because SpawnOverlay is missing from StarterGui")
local RequestChangeSpawn =
	game.ReplicatedStorage:WaitForChild("RequestChangeSpawn", 10) or
	error("MessageOverlay couldn't start because RequestChangeSpawn is missing from StarterGui")
local isSpawning = game.Players.LocalPlayer:WaitForChild("IsSpawning")

local PlayerSpawnClient = {
	isSpawning = false
}

function PlayerSpawnClient.onSpawnChange(spawnModel)
	-- Add code here or replace the function to add your own behaviour for this event
end

function PlayerSpawnClient.focusSpawn(model)
	for _, part in ipairs(model:GetDescendants()) do
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Transparency = 0
	end
end

function PlayerSpawnClient.blurSpawn(model)
	for _, part in ipairs(model:GetDescendants()) do
		part.Color = Color3.fromRGB(26, 202, 3)
		part.Transparency = 0.5
	end
end

function PlayerSpawnClient.hideSpawn(model)
	for _, part in ipairs(model:GetDescendants()) do
		part.Transparency = 1
	end
end

function PlayerSpawnClient.updateSpawning()
	if isSpawning.Value then
		PlayerSpawnClient.start()
	else
		PlayerSpawnClient.stop()
	end
end

function PlayerSpawnClient.onClick(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local spawnPart = PlayerSpawnClient.raycastHandler.hit
		local spawnModel = spawnPart and spawnPart.Parent
		if spawnPart.Parent then
			RequestChangeSpawn:InvokeServer(spawnModel)
			PlayerSpawnClient.onSpawnChange(spawnModel)
		end
	end
end

function PlayerSpawnClient.start()
	if PlayerSpawnClient.isSpawning then
		return
	end
	local spawnModels = PlayerSpawnClient.getSpawnModels()
	PlayerSpawnClient.raycastHandler = PlayerSpawnClient.getRaycastHandler(spawnModels)
	for _, model in ipairs(spawnModels) do
		PlayerSpawnClient.blurSpawn(model)
	end
	PlayerSpawnClient.isSpawning = true
	PlayerSpawnClient.inputConnection = UserInputService.InputBegan:Connect(PlayerSpawnClient.onClick)
	PlayerSpawnClient.spawnModels = spawnModels

	PlayerSpawnClient.flashText()
end

function PlayerSpawnClient.getRaycastHandler(spawnModels)
	local spawnParts = findParts(spawnModels)
	return PlayerRaycaster.addHandler(
		spawnParts,
		function(spawnPart)
			PlayerSpawnClient.focusSpawn(spawnPart.Parent)
		end,
		function(spawnPart)
			PlayerSpawnClient.blurSpawn(spawnPart.Parent)
		end
	)
end

function PlayerSpawnClient.flashText()
	spawn(
		function()
			while PlayerSpawnClient.isSpawning do
				wait(0.5)
				SpawnOverlay.Enabled = false
				wait(0.2)
				SpawnOverlay.Enabled = true
			end
		end
	)
end

function PlayerSpawnClient.stop()
	for _, model in ipairs(PlayerSpawnClient.spawnModels) do
		PlayerSpawnClient.hideSpawn(model)
	end
	SpawnOverlay.Enabled = false
	PlayerSpawnClient.raycastHandler:removeHandler()
	PlayerSpawnClient.inputConnection:Disconnect()
	PlayerSpawnClient.spawnModels = nil
	PlayerSpawnClient.raycastHandler = nil
	PlayerSpawnClient.inputConnection = nil
	PlayerSpawnClient.isSpawning = false
end

function PlayerSpawnClient.setup(getSpawnModels)
	PlayerSpawnClient.getSpawnModels = getSpawnModels
	isSpawning.Changed:Connect(
		function()
			PlayerSpawnClient.updateSpawning()
		end
	)
end

return PlayerSpawnClient
