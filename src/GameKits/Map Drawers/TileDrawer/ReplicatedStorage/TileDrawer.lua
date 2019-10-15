local MazeDrawer = {}

local MazeGenerator = require(game.ReplicatedStorage.MazeGenerator)

local function getKey(cell)
	return cell.X .. "," .. cell.Y
end

function MazeDrawer.drawTiles(options)
	-- Ensure that the inputs are valid
	local maze = options.maze
	assert(type(maze) == "table", "Maze must be a table with walls, sizeX and sizeY")

	local sizeX = maze.sizeX
	local sizeY = maze.sizeY
	local walls = maze.walls

	assert(type(sizeX) == "number" and sizeX > 0, "The sizeX of the maze must be a positive integer")
	assert(type(sizeY) == "number" and sizeY > 0, "The sizeY of the maze must be a positive integer")
	assert(type(walls) == "table", "The walls of the maze must be a table")

	local name = options.name
	local templates = options.templates
	local tileSizeX = options.tileSizeX
	local tileSizeY = options.tileSizeY
	local position = options.position or Vector3.new(0, 0, 0)

	assert(typeof(templates) == "Instance" and templates:IsA("Folder"), "The templates must be a Folder")
	assert(type(tileSizeX) == "number" and tileSizeX > 0, "The tileSizeX must be a positive integer")
	assert(type(tileSizeY) == "number" and tileSizeY > 0, "The tileSizeY must be a positive integer")
	assert(typeof(position) == "Vector3", "The position must be a Vector3")
	assert(type(name) == "string", "Name must be a string")

	local folder = Instance.new("Folder")
	folder.Name = name

	-- Iterate through every cell in the maze
	for i = 1, sizeX do
		for j = 1, sizeY do
			-- Make a list of the walls surrounding the cell
			local cellWalls = {}
			local cell = Vector2.new(i, j)
			-- Check each direction adjacent to the cell
			for _, direction in ipairs(MazeGenerator.DIRECTIONS) do
				local adjacent = cell + direction
				local wallPosition = (cell + adjacent) / 2
				local wallKey = getKey(wallPosition)
				local isWall = walls[wallKey] ~= false
				table.insert(cellWalls, isWall)
			end
			local isEmpty = maze.map and maze.map[i][j] == false
			if not isEmpty then
				-- Get a tile to use for this maze cell
				local tile = MazeDrawer.chooseTile(templates, cellWalls)
				-- Clone it and position it in the folder
				local tilePosition = CFrame.new(i * tileSizeX, 0, j * tileSizeY) + position
				local primaryPart = tile.PrimaryPart
				-- Preserve the rotation of the part when we move it
				local tileRotation = primaryPart.CFrame - primaryPart.Position
				tile:SetPrimaryPartCFrame(tilePosition * tileRotation)
				tile.Parent = folder
			end
		end
	end

	return folder
end

function MazeDrawer.chooseTile(templates, cellWalls)
	-- Count the number of walls surrounding the cell to work out what type of tile to draw
	local wallCount = MazeDrawer.getWallCount(cellWalls)
	if wallCount == 0 then
		-- A crossroads tile has no walls
		return MazeDrawer.getTileFromTemplate(templates, "Crossroads")
	elseif wallCount == 1 then
		-- A junction tile has one wall
		return MazeDrawer.chooseJunction(templates, cellWalls)
	elseif wallCount == 2 then
		-- A corner tile or straight tile has two walls
		-- Check if the walls make a horizontal or vertical straight tile
		local isVertical = cellWalls[1] and cellWalls[3]
		local isHorizontal = cellWalls[2] and cellWalls[4]
		if isVertical or isHorizontal then
			return MazeDrawer.chooseStraight(templates, isVertical)
		else
			return MazeDrawer.chooseCorner(templates, cellWalls)
		end
	elseif wallCount == 3 then
		-- An ending tile has a 3 walls
		return MazeDrawer.chooseEnding(templates, cellWalls)
	else
		-- A ground tile has 4 walls
		return MazeDrawer.getTileFromTemplate(templates, "Ground")
	end
end

function MazeDrawer.getWallCount(cellWalls)
	local wallCount = 0
	-- Count the number of true values in th cellWalls list
	for index, isWall in ipairs(cellWalls) do
		if isWall then
			wallCount = wallCount + 1
		end
	end
	return wallCount
end

-- Choose a tile based on the template name given
function MazeDrawer.getTileFromTemplate(templates, name)
	local template = templates:FindFirstChild(name)
	assert(template, "Missing the template: " .. name)
	-- If the template is folder, return a random template from that folder
	if template:IsA("Folder") then
		local children = template:GetChildren()
		return children[math.random(1, #children)]:Clone()
	else
		return template:Clone()
	end
end

function MazeDrawer.chooseJunction(templates, cellWalls)
	local tile = MazeDrawer.getTileFromTemplate(templates, "Junction")
	-- Find the rotation of the junction based on the wall found
	local wallIndex
	for i, isWall in ipairs(cellWalls) do
		if isWall then
			wallIndex = i
			break
		end
	end
	local degrees = wallIndex * 90
	local rotation = CFrame.Angles(0, math.rad(degrees), 0)
	tile:SetPrimaryPartCFrame(rotation)
	return tile
end

function MazeDrawer.chooseEnding(templates, cellWalls)
	local tile = MazeDrawer.getTileFromTemplate(templates, "Ending")
	-- Find the rotation of the ending based on the gap found
	local gapIndex
	for i, isWall in ipairs(cellWalls) do
		if not isWall then
			gapIndex = i
			break
		end
	end
	local degrees = gapIndex * 90
	local rotation = CFrame.Angles(0, math.rad(degrees), 0)
	tile:SetPrimaryPartCFrame(rotation)
	return tile
end

function MazeDrawer.chooseCorner(templates, cellWalls)
	local tile = MazeDrawer.getTileFromTemplate(templates, "Corner")
	local degrees = 0
	if cellWalls[2] and cellWalls[3] then
		degrees = 90
	elseif cellWalls[3] and cellWalls[4] then
		degrees = 180
	elseif cellWalls[4] and cellWalls[1] then
		degrees = 270
	end
	local rotation = CFrame.Angles(0, math.rad(degrees), 0)
	tile:SetPrimaryPartCFrame(rotation)
	return tile
end

function MazeDrawer.chooseStraight(templates, isVertical)
	local tile = MazeDrawer.getTileFromTemplate(templates, "Straight")
	local degrees = isVertical and 90 or 0
	local rotation = CFrame.Angles(0, math.rad(degrees), 0)
	tile:SetPrimaryPartCFrame(rotation)
	return tile
end

return MazeDrawer
