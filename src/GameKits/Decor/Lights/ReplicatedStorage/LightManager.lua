local RunService = game:GetService("RunService")
local LightManager = {
	colors = {},
	pulsating = {}
}

function LightManager.turnOff(root, name)
	for _, object in ipairs(root:GetDescendants()) do
		if object.Name == name then
			LightManager.colors[object] = object.Color
			object.Color = Color3.fromRGB(60, 60, 60)
			object.PointLight.Enabled = false
		end
	end
end

function LightManager.turnOn(root, name)
	for _, object in ipairs(root:GetDescendants()) do
		if object.Name == name then
			object.Color = LightManager.colors[object]
			object.PointLight.Color = LightManager.colors[object]
			object.PointLight.Enabled = true
		end
	end
end

function LightManager.setColor(root, name, color)
	for _, object in ipairs(root:GetDescendants()) do
		if object.Name == name then
			LightManager.colors[object] = color
			object.Color = color
		end
	end
end

function LightManager.pulsate(root, name)
	if not LightManager.hasLightPulsator then
		LightManager.addLightPulsator()
	end
	for _, object in ipairs(root:GetDescendants()) do
		if object.Name == name then
			LightManager.colors[object] = object.Color
			LightManager.pulsating[object] = {
				duration = 3,
				minBrightness = 0,
				maxBrightness = 5,
				offset = math.random()
			}
		end
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
