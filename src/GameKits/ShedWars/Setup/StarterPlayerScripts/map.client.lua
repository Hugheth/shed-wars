local buildings = game.Workspace:WaitForChild("Buildings", 1000)
local LightManager = require(game.ReplicatedStorage.LightManager)
LightManager.pulsate(buildings, "Light")
