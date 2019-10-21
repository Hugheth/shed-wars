--[[
	The purpose of this module is to provide examples of a game kit that:
	- Provides objects that methods can be called on without employing a metatable or class infrastructure
	- Provides objects that event hooks can bu customized for
	- Generalizes reuse by other game kits or separate game systems
]]
local ChoiceDialog =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("ChoiceDialog", 10) or
	error("ChoiceOverlay couldn't start because ChoiceDialog is missing from StarterGui")

local ChoiceOverlay = {}

local PADDING = 20
local SPACING = 10

function ChoiceOverlay.open(options)
	local title = options.title
	local choices = options.choices
	local buttonText = options.buttonText

	local dialog = ChoiceDialog:Clone()
	local contents = dialog.Frame.ContentFrame
	dialog.Frame.TitleFrame.Title.Text = title
	dialog.Frame.CloseButton.Text = buttonText

	local templateLabel = contents.Choice
	templateLabel.Parent = nil

	local labels = {}

	local handle = {
		dialog = dialog,
		close = ChoiceOverlay.close,
		onClose = options.onClose
	}

	local function deselectLabels()
		for _, choice in ipairs(choices) do
			labels[choice.name].BackgroundTransparency = 1
		end
	end

	local function onClick(choice)
		deselectLabels()
		handle.selectedChoice = choice
		labels[choice.name].BackgroundTransparency = 0
	end

	local function drawLabel(index, choice)
		local choiceLabel = templateLabel:Clone()
		choiceLabel.Name = choice.name
		choiceLabel.Text = choice.name
		choiceLabel.Visible = true
		choiceLabel.TextColor3 = choice.color
		choiceLabel.Position = UDim2.new(0, PADDING, 0, (index - 1) * (choiceLabel.Size.Y.Offset + SPACING) + PADDING)
		choiceLabel.MouseButton1Click:Connect(
			function()
				onClick(choice)
			end
		)
		choiceLabel.Parent = contents
		labels[choice.name] = choiceLabel
	end

	for index, choice in ipairs(choices) do
		drawLabel(index, choice)
	end

	onClick(choices[1])

	local size = #choices * (templateLabel.Size.Y.Offset + SPACING) + 2 * PADDING
	contents.CanvasSize = UDim2.new(0, 0, 0, size)

	local function onSubmit()
		handle:close()
	end

	dialog.Frame.CloseButton.MouseButton1Click:Connect(onSubmit)
	dialog.Enabled = true
	dialog.Parent = ChoiceDialog.Parent

	return handle
end

function ChoiceOverlay.close(handle)
	handle.dialog:Destroy()
	handle.onClose(handle.selectedChoice, handle)
end

return ChoiceOverlay
