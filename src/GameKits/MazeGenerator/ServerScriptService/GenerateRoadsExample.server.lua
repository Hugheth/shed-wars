local MazeGenerator = require(game.ReplicatedStorage.MazeGenerator)
local MazeDrawer = require(game.ReplicatedStorage.MazeDrawer)

local maze =
	MazeGenerator.generateMaze(
	{
		width = 9,
		height = 9,
		branchingChance = 0.3,
		blockWidth = 2,
		blockHeight = 2
	}
)

print(MazeGenerator.printMaze(maze))

local model =
	MazeDrawer.drawMaze(
	{
		maze = maze,
		cellWidth = 32,
		cellHeight = 32,
		name = "My City",
		templates = game.ServerStorage.RoadTiles
	}
)

model.Parent = game.Workspace
