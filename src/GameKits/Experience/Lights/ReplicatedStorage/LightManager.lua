local RunService = game:GetService("RunService")
local findParts = require(game.ReplicatedStorage.FindParts)
local LightManager = {
	colors = {},
	pulsating = {}
}

function LightManager.findLights(root, name)
	return findParts(root, name or "Light")
end

function LightManager.turnOff(lights)
	for _, light in ipairs(lights) do
		LightManager.colors[light] = light.Color
		light.Color = Color3.fromRGB(60, 60, 60)
		light.PointLight.Enabled = false
	end
end

function LightManager.turnOn(lights)
	for _, light in ipairs(lights) do
		light.Color = LightManager.colors[light]
		light.PointLight.Color = LightManager.colors[light]
		light.PointLight.Enabled = true
	end
end

function LightManager.setColor(lights, color)
	for _, light in ipairs(lights) do
		LightManager.colors[light] = color
		light.Color = color
	end
end

function LightManager.pulsate(lights)
	if not LightManager.hasLightPulsator then
		LightManager.addLightPulsator()
	end
	for _, light in ipairs(lights) do
		LightManager.colors[light] = light.Color
		LightManager.pulsating[light] = {
			duration = 3,
			minBrightness = 0,
			maxBrightness = 5,
			offset = math.random()
		}
	end
end

function LightManager.addLightPulsator()
	local function pulsateLights()
		for object, options in pairs(LightManager.pulsating) do
			local currentTime = options.offset + time()
			local t = math.abs(math.cos(currentTime / options.duration * math.pi))
			local brightness = t * (options.maxBrightness - options.minBrightness) + options.minBrightness
			object.PointLight.Brightness = brightness
			local preferredColor = LightManager.colors[object]
			object.Color = Color3.fromRGB(60, 60, 60):lerp(preferredColor, t)
		end
	end
	RunService.RenderStepped:Connect(pulsateLights)
	LightManager.hasLightPulsator = true
end

return LightManager
