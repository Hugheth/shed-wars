local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera

local PlayerRaycaster = {
	whitelist = {},
	connections = {}
}

function PlayerRaycaster.onStep()
	local viewportPoint = camera.ViewportSize / 2
	local unitRay = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y, 0)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * PlayerRaycaster.maxDistance)
	local part, position = workspace:FindPartOnRayWithWhitelist(ray, PlayerRaycaster.whitelist)
	print("found part", part, position)
	if part then
		local partConnections = PlayerRaycaster.connections[part]
		if partConnections then
			for _, connection in ipairs(partConnections) do
				if connection.onEnter then
					connection.onEnter(part, position)
				end
			end
		end
	end
	local previousPart = PlayerRaycaster.currentWhitelistPart
	if previousPart then
		local previousPartConnections = PlayerRaycaster.connections[previousPart]
		for _, connection in ipairs(previousPartConnections) do
			if connection.onLeave then
				connection.onLeave(PlayerRaycaster.currentWhitelistPart, PlayerRaycaster.currentWhitelistPosition)
			end
		end
	end
	PlayerRaycaster.currentWhitelistPart = part
	PlayerRaycaster.currentWhitelistPosition = position
	local currentPart, currentPosition = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
	PlayerRaycaster.currentPart = currentPart
	PlayerRaycaster.currentPosition = currentPosition
end

function PlayerRaycaster.findParts(root, name)
	local parts = {}
	for _, object in ipairs(root:GetDescendants()) do
		if object.Name == name then
			table.insert(parts, object)
		end
	end
	return parts
end

function PlayerRaycaster.connectParts(parts, onEnter, onLeave)
	local connection = {
		onEnter = onEnter,
		onLeave = onLeave,
		disconnect = PlayerRaycaster.disconnect
	}
	for _, part in ipairs(parts) do
		if not PlayerRaycaster.connections[part] then
			PlayerRaycaster.connections[part] = {}
			table.insert(PlayerRaycaster.whitelist, part)
		end
		table.insert(PlayerRaycaster.connections[part], connection)
	end
	return connection
end

function PlayerRaycaster.disconnect(connection)
	local newConnections = {}
	for part, connections in pairs(PlayerRaycaster.connections) do
		local newPartConnections = {}
		for _, partConnection in ipairs(connections) do
			if partConnection ~= connection then
				table.insert(newPartConnections, partConnection)
			end
		end
		if #newPartConnections > 0 then
			newConnections[part] = newPartConnections
		end
	end
	PlayerRaycaster.connections = newConnections
end

function PlayerRaycaster.setup(maxDistance)
	PlayerRaycaster.maxDistance = maxDistance
	RunService.RenderStepped:Connect(PlayerRaycaster.onStep)
end

return PlayerRaycaster
