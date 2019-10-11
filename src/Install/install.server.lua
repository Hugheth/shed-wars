local targets = {
	{
		name = "ReplicatedStorage",
		folder = game.ReplicatedStorage
	},
	{
		name = "ServerScriptService",
		folder = game.ServerScriptService
	}
}

local kits = game.ServerStorage.GameKits:GetChildren()
for _, kit in ipairs(kits) do
	if kit:IsA("Folder") then
		for _, target in ipairs(targets) do
			local folder = kit:FindFirstChild(target.name)
			if folder then
				for _, child in ipairs(folder:GetChildren()) do
					child.Parent = target.folder
					if child:IsA("Script") or child:IsA("LocalScript") then
						child.Disabled = false
					end
				end
			end
		end
	end
end
