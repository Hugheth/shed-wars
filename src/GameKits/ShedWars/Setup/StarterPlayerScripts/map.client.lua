local buildings = game.Workspace:WaitForChild("Buildings", 1000)
local LightManager = require(game.ReplicatedStorage.LightManager)
local lights = LightManager.findLights(buildings)
LightManager.pulsate(lights)
