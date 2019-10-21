script.Parent.Touched:Connect(
	function(part)
		local player = game.Players:GetPlayerFromCharacter(part.Parent)
		if player then
			player.Character.Humanoid.Health = 0
		end
	end
)
