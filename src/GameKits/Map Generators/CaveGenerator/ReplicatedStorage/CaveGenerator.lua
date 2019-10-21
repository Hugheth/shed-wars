--[[
	The purpose of this module is to provide examples of a game kit that:
	- Produces a result that can be used by other game kits (Tile or Building drawers)
	- Implements a complex piece of functionality but provides a simple interface
]]
local CaveGenerator = {}

function CaveGenerator.generateCave(options)
	-- Move the options to variables as they are easier to work with
	local sizeX = options.sizeX
	local sizeY = options.sizeY
	local density = options.density or 0.5
	local steps = options.steps or 4
	local birthLimit = options.birthLimit or 4
	local deathLimit = options.deathLimit or 3
	local random = options.random or Random.new()

	-- Ensure that the inputs are valid
	assert(type(sizeX) == "number" and sizeX > 0, "The sizeX of the cave must be a positive integer")
	assert(type(sizeY) == "number" and sizeY > 0, "The sizeY of the cave must be a positive integer")
	assert(type(birthLimit) == "number" and birthLimit > 0, "The birthLimit of the cave must be a positive integer")
	assert(type(deathLimit) == "number" and deathLimit > 0, "The deathLimit of the cave must be a positive integer")
	assert(
		type(density) == "number" and density >= 0 and density <= 1,
		"The density of the cave must be a number between 0 and 1"
	)
	assert(type(steps) == "number" and steps > 0, "The steps for the cave generation must be a positive integer")

	local map = {}
	for i = 1, sizeX do
		map[i] = {}
		for j = 1, sizeY do
			map[i][j] = random:NextNumber() < density and true or false
		end
	end

	-- Make a number of passes over the map to produce caves
	for n = 1, steps do
		local nextMap = {}
		for i = 1, sizeX do
			nextMap[i] = {}
			for j = 1, sizeY do
				local adjacentCount = CaveGenerator.getAdjacentCount(map, i, j)
				if map[i][j] then
					if adjacentCount < deathLimit then
						nextMap[i][j] = false
					else
						nextMap[i][j] = true
					end
				else
					if adjacentCount > birthLimit then
						nextMap[i][j] = true
					else
						nextMap[i][j] = false
					end
				end
			end
		end
		map = nextMap
	end

	return {
		sizeX = sizeX,
		sizeY = sizeY,
		map = map,
		walls = CaveGenerator.getCaveWalls(map, sizeX, sizeY)
	}
end

function CaveGenerator.getAdjacentCount(map, x, y)
	local adjacentCount = 0
	for i = x - 1, x + 1 do
		for j = y - 1, y + 1 do
			if map[i] and map[i][j] then
				adjacentCount = adjacentCount + 1
			end
		end
	end
	return adjacentCount
end

function CaveGenerator.getCaveWalls(map, sizeX, sizeY)
	local walls = {}
	for i = 1, sizeX - 1 do
		for j = 1, sizeY - 1 do
			local tile = map[i][j]
			walls[i + 0.5 .. "," .. j] = tile ~= map[i + 1][j]
			walls[i .. "," .. j + 0.5] = tile ~= map[i][j + 1]
		end
	end
	return walls
end

return CaveGenerator
