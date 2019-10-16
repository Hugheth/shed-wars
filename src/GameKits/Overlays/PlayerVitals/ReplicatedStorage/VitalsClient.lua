local TextService = game:GetService("TextService")
local VitalsOverlay =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("VitalsOverlay", 10) or
	error("VitalsClient couldn't start because VitalsOverlay is missing from StarterGui")
local VitalsClient = {}
local VitalFrame = VitalsOverlay.Frame.VitalFrame
VitalFrame.Parent = nil

local PADDING = 10
local SPACING = 20

function VitalsClient.setup(names)
	VitalsClient.names = names
	local player = game.Players.LocalPlayer
	local offset = PADDING
	local textSize = VitalFrame.VitalName.TextSize
	local font = VitalFrame.VitalName.Font

	local function initializeValue(frame, name)
		local value = player:WaitForChild(name, 10)
		frame.VitalValue.Text = value.Value
		value.Changed:Connect(
			function()
				frame.VitalValue.Text = value.Value
			end
		)
	end

	for _, name in ipairs(names) do
		local frame = VitalFrame:Clone()
		local size = TextService:GetTextSize(name, textSize, font, Vector2.new(math.huge, textSize))
		frame.VitalName.Size = UDim2.new(0, size.X, 0, size.Y)
		frame.VitalName.Text = name
		frame.VitalValue.Size = UDim2.new(0, 100, 0, size.Y)
		frame.VitalValue.Position = UDim2.new(0, size.X + PADDING, 0, 0)
		local frameWidth = size.X + 100 + 3 * PADDING
		frame.Size = UDim2.new(0, frameWidth, 0, size.Y + 2 * PADDING)
		offset = offset + frameWidth + SPACING
		frame.Parent = 	

		initializeValue(frame, name)
	end
end

return VitalsClient
