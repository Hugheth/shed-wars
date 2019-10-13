local heightmap = require(script.Parent.heightmap)

local HeightMapGenerator = {}
-- The HeightMapGenerator is based on the Diamond Square algorithm

function HeightMapGenerator.generateMap(options)
	-- Move the options to variables as they are easier to work with
	local sizeX = options.sizeX
	local sizeY = options.sizeY
	local random = options.random or Random.new()

	-- Ensure that the inputs are valid
	assert(type(sizeX) == "number" and sizeX > 0, "The sizeX of the map must be a positive integer")
	assert(type(sizeY) == "number" and sizeY > 0, "The sizeY of the map must be a positive integer")

	local function getHeight(map, x, y, depth, averageHeight)
		return averageHeight + (random:NextNumber() - 0.5) * depth
	end

	local result = heightmap(sizeX, sizeY, getHeight)

	local map = {}
	-- Copy the values from the library into our map object
	for i = 1, sizeX do
		map[i] = {}
		for j = 1, sizeY do
			map[i][j] = result[i - 1][j - 1]
		end
	end

	return {
		sizeX = sizeX,
		sizeY = sizeY,
		map = map
	}
end

return HeightMapGenerator
