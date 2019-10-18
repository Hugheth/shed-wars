local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local FloatingPlayer = require(game.ReplicatedStorage.FloatingPlayer)
local player = game.Players.LocalPlayer
local isSpectating = player:WaitForChild("IsSpectating")

local SpectatorModeClient = {
	isSpectating = false
}

function SpectatorModeClient.setup()
	SpectatorModeClient.updateFloating()
	isSpectating.Changed:Connect(
		function()
			SpectatorModeClient.updateFloating()
		end
	)
end

function SpectatorModeClient.onStep(step)
	local change = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.E) then
		change = step * 30
	elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
		change = step * -30
	end
	if change ~= 0 then
		FloatingPlayer.bodyPosition.Position = FloatingPlayer.bodyPosition.Position + Vector3.new(0, change, 0)
	end
end

function SpectatorModeClient.start()
	if SpectatorModeClient.isSpectating then
		return
	end
	SpectatorModeClient.isSpectating = true
	FloatingPlayer.start(10)
	player.Character.Humanoid.WalkSpeed = 30
	SpectatorModeClient.heartbeatConnection = RunService.Heartbeat:Connect(SpectatorModeClient.onStep)
end

function SpectatorModeClient.stop()
	if not SpectatorModeClient.isSpectating then
		return
	end
	SpectatorModeClient.isSpectating = false
	FloatingPlayer.stop()
	player.Character.Humanoid.WalkSpeed = 16
	SpectatorModeClient.heartbeatConnection:Disconnect()
	SpectatorModeClient.heartbeatConnection = nil
end

function SpectatorModeClient.updateFloating()
	if isSpectating.Value then
		SpectatorModeClient.start()
	else
		SpectatorModeClient.stop()
	end
end

return SpectatorModeClient
