--[[
	The purpose of this module is to provide examples of a game kit that:
	- Is purely client-size
	- Has an active / passive state
]]
--[[
	Camera state that sets the camera to a specified CFrame, but allows the user to move through the
	possible CFrame locations by clicking.
]]
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local camera = workspace.CurrentCamera
local LocalPlayer = game:GetService("Players").LocalPlayer

local INPUT_SENSITIVITY = 0.25
local MAX_UP = math.rad(80)
local MAX_DOWN = math.rad(-80)
local OFFSET = CFrame.new(2.5, 0.5, 4)
local CLIP_THRESHOLD = 0.5

local OverShoulderCamera = {}
local connections = {}

local cameraAngles

--[[
	Checks to see if there is substantial blocking between the camera and the character - if there is, the target CFrame will be close enough to the character whereby
	clipping no longer occurs
]]
local function calculateClipping(character, rootPosition, targetCFrame)
	local ray = Ray.new(rootPosition, (targetCFrame.Position - rootPosition))

	local _, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, {character})

	local cameraOffset = (hitPosition - targetCFrame.Position)

	local clippingRatio = cameraOffset.magnitude
	local clippingSpace =
		(math.clamp(clippingRatio - CLIP_THRESHOLD, 0, CLIP_THRESHOLD) / CLIP_THRESHOLD) * Vector3.new(1.2, 0, 0)

	return targetCFrame * CFrame.new(clippingSpace) + cameraOffset
end

--[[
	Sets the camera CFrame to specified location
]]
local function updateCamera()
	local character = LocalPlayer.Character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head then
		return
	end

	local headOffset = head.Position - character.PrimaryPart.Position

	local rootPosition = LocalPlayer.Character.PrimaryPart.Position + headOffset
	local rotation = CFrame.Angles(0, cameraAngles.X, 0) * CFrame.Angles(cameraAngles.Y, 0, 0)

	local targetCFrame = CFrame.new(rootPosition) * rotation * OFFSET

	camera.CFrame = calculateClipping(character, rootPosition, targetCFrame)
end

--[[
	Gets the locations, and then sets the camera. Binds the actions of moving the camera between the different
	locations.
]]
function OverShoulderCamera.start()
	camera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false

	cameraAngles = Vector2.new()

	wait()

	RunService:BindToRenderStep(
		"OverShoulderCamera",
		Enum.RenderPriority.Camera.Value,
		function(deltaTime)
			camera.Focus = camera.CFrame
			updateCamera()
		end
	)

	local function onInputChanged(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inputObject.Delta * UserGameSettings.MouseSensitivity * INPUT_SENSITIVITY
			local y = math.clamp(cameraAngles.Y - math.rad(delta.Y), MAX_DOWN, MAX_UP)
			local x = cameraAngles.X - math.rad(delta.X)
			cameraAngles = Vector2.new(x, y)
		end
	end

	connections.mouseInput = UserInputService.InputChanged:Connect(onInputChanged)

	-- There is a bug with Studio only, whereby if MouseBehaviour is LockCenter when the screen is focused again, mouse delta no longer works
	connections.screenLoseFocus =
		UserInputService.WindowFocusReleased:Connect(
		function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	)
	connections.screenFocus =
		UserInputService.WindowFocused:Connect(
		function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	)
end

--[[
	Cleans up the bound actions
]]
function OverShoulderCamera.stop()
	wait()
	UserInputService.MouseIconEnabled = true
	RunService:UnbindFromRenderStep("OverShoulderCamera")
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end
end

return OverShoulderCamera
