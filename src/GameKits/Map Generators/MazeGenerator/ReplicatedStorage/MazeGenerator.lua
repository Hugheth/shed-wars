--[[
	The purpose of this module is to provide examples of a game kit that:
	- Produces a result that can be used by other game kits (Tile or Building drawers)
	- Implements a complex piece of functionality but provides a simple interface
]]
local MazeGenerator = {}

-- Store the different directions that you can go in the maze
local UP = Vector2.new(0, -1)
local DOWN = Vector2.new(0, 1)
local LEFT = Vector2.new(1, 0)
local RIGHT = Vector2.new(-1, 0)

MazeGenerator.DIRECTIONS = {RIGHT, DOWN, LEFT, UP}

local function getKey(cell)
	return cell.X .. "," .. cell.Y
end

function MazeGenerator.generateMaze(options)
	-- Move the options to variables as they are easier to work with
	local sizeX = options.sizeX
	local sizeY = options.sizeY
	local branchingChance = options.branchingChance or 0
	local blockSizeX = options.blockSizeX or 1
	local blockSizeY = options.blockSizeY or 1
	local random = options.random or Random.new()

	-- Ensure that the inputs are valid
	assert(type(sizeX) == "number" and sizeX > 0, "The sizeX of the maze must be a positive integer")
	assert(type(sizeY) == "number" and sizeY > 0, "The sizeY of the maze must be a positive integer")
	assert(type(blockSizeX) == "number" and blockSizeX > 0, "The blockSizeX of the maze must be a positive integer")
	assert(type(blockSizeY) == "number" and blockSizeY > 0, "The blockSizeY of the maze must be a positive integer")
	assert(
		type(branchingChance) == "number" and branchingChance >= 0 and branchingChance <= 1,
		"The branching chance must be a number between 0 and 1"
	)

	-- Create an object to store the walls of the maze
	local walls = {}

	-- Let's start in the center of the maze
	local middleX = sizeX / 2
	local middleY = sizeY / 2
	-- Pick a cell which isn't in a wall
	local emptyX = middleX - middleX % blockSizeX + 1
	local emptyY = middleY - middleY % blockSizeY + 1
	local firstCell = Vector2.new(emptyX, emptyY)

	-- Store a list of cells we want to visit in the maze
	local cells = {firstCell}
	-- Store a list of cells we've already visited in the maze
	local visited = {}

	-- We use this function to swap the cell to look at next, if we run out of routes
	-- or we decide to take a different branch
	local function chooseNewCell()
		if #cells < 2 then
			return
		end
		local nextIndex = random:NextInteger(1, #cells)
		local previousCell = cells[#cells]
		cells[#cells] = cells[nextIndex]
		cells[nextIndex] = previousCell
	end

	-- Make a maze by visiting the cells and trying to move to another one
	while #cells > 0 do
		-- Pick the most recent cell that was added
		local cell = cells[#cells]
		-- Mark the cell as visited
		visited[getKey(cell)] = true
		-- Get all the cells adjacent to this one
		local adjacents = {}
		for i, direction in ipairs(MazeGenerator.DIRECTIONS) do
			local adjacent = cell + direction
			-- Check that this cell is in the maze
			local isInside = MazeGenerator.cellIsInside(adjacent, sizeX, sizeY)
			-- Check that the cell is empty
			local isEmpty = not MazeGenerator.cellIsWall(adjacent, blockSizeX, blockSizeY)
			if isInside and isEmpty then
				-- Locate the wall halfway between the two cells
				local wallPosition = (adjacent + cell) / 2
				local wallKey = getKey(wallPosition)
				-- If the cell has already been visited then add a wall
				if visited[getKey(adjacent)] then
					-- Add a wall if we haven't already made an opening
					if walls[wallKey] ~= false then
						walls[wallKey] = true
					end
				else
					table.insert(adjacents, adjacent)
				end
			end
		end

		-- Check that there is a free direction to go in
		if #adjacents > 0 then
			-- Pick a random adjacent cell to move to next
			local nextIndex = random:NextInteger(1, #adjacents)
			local nextCell = adjacents[nextIndex]
			table.insert(cells, nextCell)

			-- Make an opening between the two cells
			local wallPosition = (nextCell + cell) / 2
			local wallKey = getKey(wallPosition)
			walls[wallKey] = false

			-- Choose a new cell if the branching chance is exceeded
			if random:NextNumber() < branchingChance then
				chooseNewCell()
			end
		else
			-- There's no routes from this cell, so remove it from the list
			table.remove(cells)
			-- Choose a new cell
			chooseNewCell()
		end
	end

	return {
		walls = walls,
		sizeX = sizeX,
		sizeY = sizeY
	}
end

function MazeGenerator.cellIsWall(cell, blockSizeX, blockSizeY)
	return (cell.X - 1) % blockSizeX ~= 0 and (cell.Y - 1) % blockSizeY ~= 0
end

function MazeGenerator.cellIsInside(cell, sizeX, sizeY)
	if cell.X < 1 or cell.X > sizeX then
		return false
	elseif cell.Y < 1 or cell.Y > sizeY then
		return false
	else
		return true
	end
end

-- Print a maze as an ascii picture
function MazeGenerator.printMaze(maze)
	local output = ""
	for i = 0.5, maze.sizeX + 0.5, 0.5 do
		for j = 0.5, maze.sizeY + 0.5, 0.5 do
			local fractionX = math.floor(i) ~= i
			local fractionY = math.floor(j) ~= j
			local symbol
			local position = Vector2.new(i, j)
			local isWall = maze.walls[getKey(position)] ~= false
			if fractionX and fractionY then
				symbol = "+"
			elseif fractionX and not fractionY and isWall then
				symbol = "-"
			elseif not fractionX and fractionY and isWall then
				symbol = "|"
			else
				symbol = " "
			end
			output = output .. symbol
		end
		output = output .. "\n"
	end
	return output
end

return MazeGenerator
