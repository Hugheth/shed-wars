local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local mouse = player:GetMouse()

local camera = workspace.CurrentCamera

local PlayerRaycaster = {
	whitelist = {},
	connections = {}
}

function PlayerRaycaster.onStep()
	local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y, 0)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * PlayerRaycaster.maxDistance)
	local part, position = workspace:FindPartOnRayWithWhitelist(ray, PlayerRaycaster.whitelist)
	local previousPart = PlayerRaycaster.currentWhitelistPart
	if previousPart and previousPart ~= part then
		local previousPartConnections = PlayerRaycaster.connections[previousPart]
		if previousPartConnections then
			for _, connection in ipairs(previousPartConnections) do
				if connection.onLeave then
					connection.hit = nil
					connection.onLeave(PlayerRaycaster.currentWhitelistPart, PlayerRaycaster.currentWhitelistPosition)
				end
			end
		end
	end
	if part and previousPart ~= part then
		local partConnections = PlayerRaycaster.connections[part]
		if partConnections then
			for _, connection in ipairs(partConnections) do
				if connection.onEnter then
					connection.hit = part
					connection.onEnter(part, position)
				end
			end
		end
	end
	PlayerRaycaster.currentWhitelistPart = part
	PlayerRaycaster.currentWhitelistPosition = position
	local currentPart, currentPosition = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
	PlayerRaycaster.currentPart = currentPart
	PlayerRaycaster.currentPosition = currentPosition
end

function PlayerRaycaster.addHandler(parts, onEnter, onLeave)
	local connection = {
		onEnter = onEnter,
		onLeave = onLeave,
		removeHandler = PlayerRaycaster.removeHandler
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

function PlayerRaycaster.removeHandler(connection)
	local newConnections = {}
	local newWhitelist = {}
	for part, connections in pairs(PlayerRaycaster.connections) do
		local newPartConnections = {}
		for _, partConnection in ipairs(connections) do
			if partConnection ~= connection then
				table.insert(newPartConnections, partConnection)
			end
		end
		if #newPartConnections > 0 then
			newConnections[part] = newPartConnections
			table.insert(newWhitelist, part)
		end
	end
	PlayerRaycaster.connections = newConnections
	PlayerRaycaster.whitelist = newWhitelist
end

function PlayerRaycaster.setup(maxDistance)
	PlayerRaycaster.maxDistance = maxDistance
	RunService.RenderStepped:Connect(PlayerRaycaster.onStep)
end

return PlayerRaycaster
