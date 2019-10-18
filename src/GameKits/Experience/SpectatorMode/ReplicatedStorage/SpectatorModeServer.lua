local PhysicsService = game:GetService("PhysicsService")
local SPECTATORS = "Spectators"
PhysicsService:CreateCollisionGroup(SPECTATORS)
PhysicsService:CollisionGroupSetCollidable(SPECTATORS, "Default", false)

local SpectatorModeServer = {}

function SpectatorModeServer.activate(player)
	if not player:FindFirstChild("IsSpectating") then
		local isSpectating = Instance.new("BoolValue")
		isSpectating.Name = "IsSpectating"
		isSpectating.Value = true
		isSpectating.Parent = player
	end

	local character = player.Character or player.CharacterAdded:Wait()
	player.IsSpectating.Value = true
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, SPECTATORS)
			part.Transparency = 1
		end
	end
end

function SpectatorModeServer.deactivate(player)
	player.IsSpectating.Value = true
end

return SpectatorModeServer
