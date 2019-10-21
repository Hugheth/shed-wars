local targets = {
	{
		name = "ReplicatedStorage",
		folder = game.ReplicatedStorage
	},
	{
		name = "ReplicatedFirst",
		folder = game.ReplicatedFirst
	},
	{
		name = "ServerScriptService",
		folder = game.ServerScriptService
	},
	{
		name = "StarterPlayerScripts",
		folder = game.StarterPlayer.StarterPlayerScripts
	}
}

local sceneScripts = {}

local categories = game.ServerStorage.GameKits:GetChildren()
for _, category in ipairs(categories) do
	local kits = category:GetChildren()
	for _, kit in ipairs(kits) do
		if kit:IsA("Folder") then
			for _, target in ipairs(targets) do
				local folder = kit:FindFirstChild(target.name)
				if folder then
					for _, child in ipairs(folder:GetChildren()) do
						child.Parent = target.folder
						if child:IsA("Script") or child:IsA("LocalScript") then
							table.insert(sceneScripts, child)
						end
					end
				end
			end
		end
	end
end

for _, scene in ipairs(sceneScripts) do
	scene.Disabled = false
end
