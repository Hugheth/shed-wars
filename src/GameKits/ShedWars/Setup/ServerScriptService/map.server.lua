local CaveGenerator = require(game.ReplicatedStorage.CaveGenerator)
local TileDrawer = require(game.ReplicatedStorage.TileDrawer)
local HeightMapGenerator = require(game.ReplicatedStorage.HeightMapGenerator)
local MazeGenerator = require(game.ReplicatedStorage.MazeGenerator)
local LightManager = require(game.ReplicatedStorage.LightManager)
local BuildingDrawer = require(game.ReplicatedStorage.BuildingDrawer)

local function drawIsland()
	local islandSizeX = 24
	local islandSizeY = 24
	local cave =
		CaveGenerator.generateCave(
		{
			sizeX = islandSizeX,
			sizeY = islandSizeY,
			density = 0.3
		}
	)
	local tiles =
		TileDrawer.drawTiles(
		{
			maze = cave,
			tileSizeX = 16,
			tileSizeY = 16,
			name = "Island",
			templates = game.ServerStorage.SwampTiles
		}
	)
	local height =
		HeightMapGenerator.generateMap(
		{
			sizeX = islandSizeX,
			sizeY = islandSizeY
		}
	)
	tiles.Parent = game.Workspace

	local x = 1
	local y = 1
	for _, tile in ipairs(tiles:GetChildren()) do
		local cframe = tile:GetPrimaryPartCFrame()
		local heightOffset = Vector3.new(0, height.map[x][y] / 2 + 5, 0)
		tile:SetPrimaryPartCFrame(cframe + heightOffset)
		x = x + 1
		if x > islandSizeX then
			x = 1
			y = y + 1
		end
	end
end

local plotSizeX = 5
local plotSizeY = 5
local walkwaySize = 60
local roomSize = 20

local function drawWalkway()
	local maze =
		MazeGenerator.generateMaze(
		{
			sizeX = plotSizeX + 1,
			sizeY = plotSizeY + 1,
			branchingChance = 0.3
		}
	)
	local walkway =
		TileDrawer.drawTiles(
		{
			maze = maze,
			tileSizeX = walkwaySize,
			tileSizeY = walkwaySize,
			name = "Walkway",
			templates = game.ServerStorage.WalkwayTiles
		}
	)
	walkway.Parent = game.Workspace
	return walkway
end

local function drawBuilding(x, y)
	local foundation = game.ServerStorage.Foundation
	local position = Vector3.new(x * walkwaySize, 0, y * walkwaySize)
	for i = 1, 2 do
		for j = 1, 2 do
			local tile = foundation:Clone()
			tile:SetPrimaryPartCFrame(CFrame.new(position + Vector3.new(i * roomSize, 0, j * roomSize)))
			tile.Parent = game.Workspace
		end
	end

	local height = math.random(1, 5)
	local floors = {}
	for i = 1, height do
		table.insert(
			floors,
			MazeGenerator.generateMaze(
				{
					sizeX = 2,
					sizeY = 2,
					branchingChance = 0.5
				}
			)
		)
	end

	local isRedTeam = y < 3
	local isBlueTeam = y > 3
	local buildingName = isRedTeam and "RedShed" or isBlueTeam and "BlueShed" or "NeutralShed"

	local buildingOffset = Vector3.new(roomSize, 24, roomSize)
	local building =
		BuildingDrawer.drawBuilding(
		{
			floors = floors,
			tileSizeX = 20,
			tileSizeY = 20,
			floorHeight = 16,
			interiorWallChance = 0.2,
			position = position + buildingOffset,
			name = buildingName,
			templates = game.ServerStorage.ShedSet
		}
	)
	local lights = LightManager.findLights(building)
	if isRedTeam then
		LightManager.setColor(lights, Color3.fromRGB(136, 1, 20))
	elseif isBlueTeam then
		LightManager.setColor(lights, Color3.fromRGB(1, 136, 136))
	else
		LightManager.setColor(lights, Color3.fromRGB(180, 180, 180))
	end
	return building
end

local function drawBuildings()
	local buildings = Instance.new("Folder")
	buildings.Name = "Buildings"
	for i = 1, plotSizeX do
		for j = 1, plotSizeY do
			local building = drawBuilding(i, j)
			building.Parent = buildings
		end
	end
	buildings.Parent = game.Workspace
end

drawIsland()
local walkway = drawWalkway()
drawBuildings()

local lights = LightManager.findLights(walkway)
LightManager.setColor(lights, Color3.fromRGB(180, 180, 180))
