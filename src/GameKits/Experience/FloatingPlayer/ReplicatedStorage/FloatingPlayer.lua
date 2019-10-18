local FloatingPlayer = {}

function FloatingPlayer.start(initialHeight)
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = character.PrimaryPart.Position + Vector3.new(0, initialHeight, 0)
	bodyPosition.MaxForce = Vector3.new(0, 1000000, 0)
	bodyPosition.Parent = character.PrimaryPart

	FloatingPlayer.bodyPosition = bodyPosition
end

function FloatingPlayer.stop()
	FloatingPlayer.bodyPosition:Destroy()
	FloatingPlayer.bodyPosition = nil
end

return FloatingPlayer
