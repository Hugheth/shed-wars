local MiningClient = require(game.ReplicatedStorage.MiningClient)

local function onActivation()
	print("Connect activation!")
	MiningClient.mine()
end

script.Parent.Activated:Connect(onActivation)
