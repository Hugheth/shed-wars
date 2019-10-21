local UserInputService = game:GetService("UserInputService")
local RequestMine =
	game.ReplicatedStorage:WaitForChild("RequestMine", 10) or
	error("MiningClient couldn't start because RequestMine is missing from StarterGui")

local PlayerRaycaster = require(game.ReplicatedStorage.PlayerRaycaster)

local MiningClient = {}

function MiningClient.setup(getMineableParts)
	MiningClient.getMineableParts = getMineableParts
end

function MiningClient.start()
	if MiningClient.active then
		return
	end
	local parts = MiningClient.getMineableParts()
	MiningClient.raycastHandler = MiningClient.getRaycastHandler(parts)
	MiningClient.inputConnection = UserInputService.InputBegan:Connect(MiningClient.onClick)
	MiningClient.active = true
end

function MiningClient.stop()
	if not MiningClient.active then
		return
	end
	MiningClient.raycastHandler:removeHandler()
	MiningClient.raycastHandler = nil
	MiningClient.active = false
end

function MiningClient.getRaycastHandler(parts)
	return PlayerRaycaster.addHandler(
		parts,
		function(part)
			part.Color = Color3.fromRGB(192, 185, 193)
		end,
		function(part)
			part.Color = Color3.fromRGB(92, 85, 93)
		end
	)
end

function MiningClient.mine()
	local part = MiningClient.raycastHandler.hit

	if part then
		RequestMine:InvokeServer(part)
	end
end

function MiningClient.onClick(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		MiningClient.mine()
	end
end

return MiningClient
