local PhysicsService = game:GetService("PhysicsService")
local DEFAULT = "Default"
local SPECTATORS = "Spectators"
PhysicsService:CreateCollisionGroup(SPECTATORS)
PhysicsService:CollisionGroupSetCollidable(SPECTATORS, DEFAULT, false)

local SpectatorModeServer = {}

function SpectatorModeServer.onJoin(player)
	local isSpectating = Instance.new("BoolValue")
	isSpectating.Name = "IsSpectating"
	isSpectating.Value = false
	isSpectating.Parent = player
end

function SpectatorModeServer.activate(player)
	player.IsSpectating.Value = true
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, SPECTATORS)
			part.Transparency = 1
		end
	end
end

function SpectatorModeServer.deactivate(player)
	player.IsSpectating.Value = false
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, DEFAULT)
			part.Transparency = 0
		end
	end
end

function SpectatorModeServer.setup()
	game.Players.PlayerAdded:Connect(SpectatorModeServer.onJoin)
end

return SpectatorModeServer
