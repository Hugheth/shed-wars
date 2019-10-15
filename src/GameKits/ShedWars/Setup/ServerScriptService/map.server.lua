local CaveGenerator = require(game.ReplicatedStorage.CaveGenerator)
local TileDrawer = require(game.ReplicatedStorage.TileDrawer)
local HeightMapGenerator = require(game.ReplicatedStorage.HeightMapGenerator)
local sizeX = 24
local sizeY = 24
local cave =
	CaveGenerator.generateCave(
	{
		sizeX = sizeX,
		sizeY = sizeY,
		density = 0.3
	}
)
local tiles =
	TileDrawer.drawTiles(
	{
		maze = cave,
		tileSizeX = 16,
		tileSizeY = 16,
		position = Vector3.new(-192, 0, -192),
		name = "My Island",
		templates = game.ServerStorage.SwampTiles
	}
)
local height =
	HeightMapGenerator.generateMap(
	{
		sizeX = sizeX,
		sizeY = sizeY
	}
)
tiles.Parent = game.Workspace
local x = 1
local y = 1
local minHeight = math.huge
local maxHeight = -math.huge
for _, tile in ipairs(tiles:GetChildren()) do
	local cframe = tile:GetPrimaryPartCFrame()
	local heightOffset = Vector3.new(0, height.map[x][y] / 2 + 7, 0)
	minHeight = math.min(minHeight, height.map[x][y])
	maxHeight = math.max(maxHeight, height.map[x][y])
	tile:SetPrimaryPartCFrame(cframe + heightOffset)
	x = x + 1
	if x > sizeX then
		x = 1
		y = y + 1
	end
end

print("Heights", minHeight, maxHeight)

local MazeGenerator = require(game.ReplicatedStorage.MazeGenerator)
local maze =
	MazeGenerator.generateMaze(
	{
		sizeX = 5,
		sizeY = 5,
		branchingChance = 0.3
	}
)
print(MazeGenerator.printMaze(maze))
local walkway =
	TileDrawer.drawTiles(
	{
		maze = maze,
		tileSizeX = 60,
		tileSizeY = 60,
		position = Vector3.new(-150, 0, -150),
		name = "Walkway",
		templates = game.ServerStorage.WalkwayTiles
	}
)
walkway.Parent = game.Workspace
