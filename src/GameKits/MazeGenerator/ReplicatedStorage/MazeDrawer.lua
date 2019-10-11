local MazeDrawer = {}

local MazeGenerator = require(game.ReplicatedStorage.MazeGenerator)

local function getKey(cell)
	return cell.X .. "," .. cell.Y
end

function MazeDrawer.drawMaze(options)
	local maze = options.maze
	assert(type(maze) == "table", "Maze must be a table with walls, width and height")

	local width = maze.width
	local height = maze.height
	local walls = maze.walls

	assert(type(width) == "number" and width > 0, "The width of the maze must be a positive integer")
	assert(type(height) == "number" and height > 0, "The height of the maze must be a positive integer")
	assert(type(walls) == "table", "The walls of the maze must be a table")

	local name = options.name
	local templates = options.templates
	local cellWidth = options.cellWidth
	local cellHeight = options.cellHeight

	assert(typeof(templates) == "Instance" and templates:IsA("Folder"), "The templates must be a Folder")
	assert(type(cellWidth) == "number" and cellWidth > 0, "The cellWidth must be a positive integer")
	assert(type(cellHeight) == "number" and cellHeight > 0, "The cellHeight must be a positive integer")
	assert(type(name) == "string", "Name must be a string")

	local model = Instance.new("Model")
	model.Name = name

	-- Iterate through every cell in the maze
	for i = 1, width do
		for j = 1, height do
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
			-- Get a tile to use for this maze cell
			local tile = MazeDrawer.chooseTile(templates, cellWalls)
			-- Clone it and position it in the model
			local tilePosition = CFrame.new(i * cellWidth, 0, j * cellHeight)
			local primaryPart = tile.PrimaryPart
			local tileRotation = primaryPart.CFrame - primaryPart.Position
			tile:SetPrimaryPartCFrame(tilePosition * tileRotation)
			tile.Parent = model

			-- Set the first tile to the model's primary part
			if i == 0 and j == 0 then
				model.PrimaryPart = tile
			end
		end
	end

	return model
end

function MazeDrawer.chooseTile(templates, cellWalls)
	-- Count the number of walls surrounding the cell to work out what type of tile to draw
	local wallCount = MazeDrawer.getWallCount(cellWalls)
	if wallCount == 0 then
		return MazeDrawer.getTileFromTemplate(templates, "Crossroads")
	elseif wallCount == 1 then
		return MazeDrawer.chooseJunction(templates, cellWalls)
	elseif wallCount == 2 then
		local isVertical = cellWalls[1] and cellWalls[3]
		local isHorizontal = cellWalls[2] and cellWalls[4]
		if isVertical or isHorizontal then
			return MazeDrawer.chooseStraight(templates, isVertical)
		else
			return MazeDrawer.chooseCorner(templates, cellWalls)
		end
	elseif wallCount == 3 then
		return MazeDrawer.chooseEnding(templates, cellWalls)
	else
		return MazeDrawer.getTileFromTemplate(templates, "Ground")
	end
end

function MazeDrawer.getWallCount(cellWalls)
	local wallCount = 0
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
