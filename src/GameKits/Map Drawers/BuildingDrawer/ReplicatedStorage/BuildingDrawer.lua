local BuildingDrawer = {}

function BuildingDrawer.drawBuilding(options)
	local floors = options.floors
	assert(type(floors) == "table", "The floors must be a table")

	local name = options.name
	local templates = options.templates
	local tileSizeX = options.tileSizeX
	local tileSizeY = options.tileSizeY
	local floorHeight = options.floorHeight

	options.random = options.random or Random.new()
	options.tileFillChance = options.tileFillChance or 0.5
	options.interiorWallChance = options.interiorWallChance or 0.5

	options.position = options.position or Vector3.new(0, 0, 0)

	assert(typeof(templates) == "Instance" and templates:IsA("Folder"), "The templates must be a Folder")
	assert(type(tileSizeX) == "number" and tileSizeX > 0, "The tileSizeX must be a positive integer")
	assert(type(tileSizeY) == "number" and tileSizeY > 0, "The tileSizeY must be a positive integer")
	assert(
		type(options.interiorWallChance) == "number" and options.interiorWallChance >= 0 and options.interiorWallChance <= 1,
		"The interiorWallChance must be a number between 0 and 1"
	)
	assert(
		type(options.tileFillChance) == "number" and options.tileFillChance >= 0 and options.tileFillChance <= 1,
		"The tileFillChance must be a number between 0 and 1"
	)
	assert(type(floorHeight) == "number" and floorHeight > 0, "The floorHeight must be a positive integer")
	assert(type(name) == "string", "Name must be a string")

	options.stairs = options.stairs or BuildingDrawer.pickStairs(options)

	local folder = Instance.new("Folder")
	folder.Name = name

	-- Iterate through each floor of the building
	for floorNumber, floor in ipairs(floors) do
		local floorFolder = Instance.new("Folder")
		floorFolder.Name = "Floor " .. floorNumber
		-- Iterate through each room
		for i = 1, floor.sizeX do
			for j = 1, floor.sizeY do
				local isEmpty = floor.map and floor.map[i][j] == false
				if not isEmpty then
					local room = BuildingDrawer.drawRoom(options, floorNumber, i, j)
					room.Parent = floorFolder
				end
			end
		end
		-- Draw the exterior walls
		for i = 1, floor.sizeX do
			local isEmpty = floor.map and floor.map[i][floor.sizeY] == false
			if not isEmpty then
				local roomPosition =
					Vector3.new((i - 1) * options.tileSizeX, (floorNumber - 1) * options.floorHeight, floor.sizeY * options.tileSizeY)
				local horizontalWall = BuildingDrawer.drawHorizontalWall(options, floorNumber, i, floor.sizeY + 1, roomPosition)
				horizontalWall.Parent = folder
			end
		end
		for j = 1, floor.sizeY do
			local isEmpty = floor.map and floor.map[floor.sizeX][j] == false
			if not isEmpty then
				local roomPosition =
					Vector3.new(floor.sizeX * options.tileSizeX, (floorNumber - 1) * options.floorHeight, (j - 1) * options.tileSizeY)
				local verticalWall = BuildingDrawer.drawVerticalWall(options, floorNumber, floor.sizeX + 1, j, roomPosition)
				verticalWall.Parent = folder
			end
		end
		floorFolder.Parent = folder
	end

	return folder
end

function BuildingDrawer.pickStairs(options)
	local stairs = {}
	local downStairsPosition
	local stairPosition
	for floorNumber = 1, #options.floors - 1 do
		local floor = options.floors[floorNumber]
		if floor.sizeX > 1 and floor.sizeY > 1 then
			while stairPosition == downStairsPosition do
				local x = options.random:NextInteger(1, floor.sizeX)
				local y = options.random:NextInteger(1, floor.sizeY)
				stairPosition = Vector2.new(x, y)
			end
			table.insert(stairs, stairPosition)
			downStairsPosition = stairPosition
		end
	end
	return stairs
end

function BuildingDrawer.drawRoom(options, floorNumber, x, y)
	local folder = Instance.new("Folder")
	folder.Name = "Room (" .. x .. "," .. y .. ")"
	local roomPosition =
		Vector3.new((x - 1) * options.tileSizeX, (floorNumber - 1) * options.floorHeight, (y - 1) * options.tileSizeY)

	local horizontalWall, isHorizontalDoor = BuildingDrawer.drawHorizontalWall(options, floorNumber, x, y, roomPosition)
	if horizontalWall then
		horizontalWall.Parent = folder
	end

	local verticalWall, isVerticalDoor = BuildingDrawer.drawVerticalWall(options, floorNumber, x, y, roomPosition)
	if verticalWall then
		verticalWall.Parent = folder
	end

	local isFilled = options.random:NextNumber() < options.tileFillChance and not isHorizontalDoor and not isVerticalDoor
	local roomTile, ceilingTile = BuildingDrawer.drawTile(options, floorNumber, x, y, roomPosition, isFilled)
	roomTile.Parent = folder
	if ceilingTile then
		ceilingTile.Parent = folder
	end

	return folder
end

function BuildingDrawer.drawHorizontalWall(options, floorNumber, x, y, roomPosition)
	local wallKey = x - 0.5 .. "," .. y
	local floor = options.floors[floorNumber]
	local isWall = floor.walls[wallKey] ~= false
	local tileName = "InteriorWall"
	local isDoor = false
	if y == 1 or y > floor.sizeY then
		tileName = "ExteriorWall"
		if floorNumber == 1 and options.random:NextNumber() < 0.5 then
			tileName = "ExteriorDoorWall"
			isDoor = true
		end
	elseif not isWall then
		if options.random:NextNumber() < options.interiorWallChance then
			tileName = "InteriorDoorWall"
			isDoor = true
		else
			return
		end
	end

	local horizontalWall = BuildingDrawer.getTileFromTemplate(options.templates, tileName, options.random)
	local wallPosition = roomPosition + Vector3.new(0, options.floorHeight / 2, -options.tileSizeY / 2)
	local wallRotation = CFrame.Angles(0, 0, 0)
	horizontalWall:SetPrimaryPartCFrame(CFrame.new(wallPosition + options.position) * wallRotation)
	return horizontalWall, isDoor
end

function BuildingDrawer.drawVerticalWall(options, floorNumber, x, y, roomPosition)
	local wallKey = x .. "," .. y - 0.5
	local floor = options.floors[floorNumber]
	local isWall = floor.walls[wallKey] ~= false
	local tileName = "InteriorWall"
	local isDoor = false
	if x == 1 or x > floor.sizeX then
		tileName = "ExteriorWall"
		if floorNumber == 1 and options.random:NextNumber() < 0.5 then
			tileName = "ExteriorDoorWall"
			isDoor = true
		end
	elseif not isWall then
		if options.random:NextNumber() < options.interiorWallChance then
			tileName = "InteriorDoorWall"
			isDoor = true
		else
			return
		end
	end

	local verticalWall = BuildingDrawer.getTileFromTemplate(options.templates, tileName, options.random)
	local wallPosition = roomPosition + Vector3.new(-options.tileSizeX / 2, options.floorHeight / 2, 0)
	local wallRotation = CFrame.Angles(0, math.rad(270), 0)
	verticalWall:SetPrimaryPartCFrame(CFrame.new(wallPosition + options.position) * wallRotation)
	return verticalWall, isDoor
end

function BuildingDrawer.drawTile(options, floorNumber, x, y, roomPosition, isFilled)
	-- Pick a tile
	local templateName = isFilled and "Decoration" or "Corridor"
	local hasCeiling = true

	local stairs = options.stairs[floorNumber]
	if stairs and stairs.X == x and stairs.Y == y then
		templateName = "Stairs"
		hasCeiling = false
	end
	local upStairs = options.stairs[floorNumber - 1]
	if upStairs and upStairs.X == x and upStairs.Y == y then
		templateName = "Upstairs"
	end

	local tile = BuildingDrawer.getTileFromTemplate(options.templates, templateName, options.random)
	tile:SetPrimaryPartCFrame(CFrame.new(roomPosition + options.position))

	local ceilingTile
	if hasCeiling then
		-- Pick a ceiling
		ceilingTile = BuildingDrawer.getTileFromTemplate(options.templates, "Ceiling", options.random)
		local ceilingPosition = roomPosition + Vector3.new(0, options.floorHeight - 0.5, 0)
		ceilingTile:SetPrimaryPartCFrame(CFrame.new(ceilingPosition + options.position))
	end

	return tile, ceilingTile
end

-- Choose a tile based on the template name given
function BuildingDrawer.getTileFromTemplate(templates, name, random)
	local template = templates:FindFirstChild(name)
	assert(template, "Missing the template: " .. name)
	-- If the template is folder, return a random template from that folder
	if template:IsA("Folder") then
		local children = template:GetChildren()
		return children[random:NextInteger(1, #children)]:Clone()
	else
		return template:Clone()
	end
end

return BuildingDrawer
