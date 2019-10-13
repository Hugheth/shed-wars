local MazeGenerator = require(game.ReplicatedStorage.MazeGenerator)
local BuildingDrawer = require(game.ReplicatedStorage.BuildingDrawer)
local floors = {}

for i = 1, 3 do
	table.insert(
		floors,
		MazeGenerator.generateMaze(
			{
				sizeX = 5,
				sizeY = 5,
				branchingChance = 1
			}
		)
	)
end

local building =
	BuildingDrawer.drawBuilding(
	{
		floors = floors,
		tileSizeX = 16,
		tileSizeY = 16,
		wallSize = 1,
		floorHeight = 16,
		interiorWallChance = 0.2,
		name = "My Building",
		templates = game.ServerStorage.BuildingSet
	}
)
building.Parent = game.Workspace
