--[[
	The purpose of this module is to provide examples of a game kit that:
	- Provides objects that methods can be called on without employing a metatable or class infrastructure
	- Provides objects that event hooks can bu customized for
	- Generalizes reuse by other game kits or separate game systems
	- Measuing UI to fit content dynamically without a library
]]
local TextService = game:GetService("TextService")
local MessageDialog =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("MessageDialog", 10) or
	error("MessageOverlay couldn't start because MessageDialog is missing from StarterGui")

local MessageOverlay = {}

local PADDING = 20

function MessageOverlay.open(title, text)
	local dialog = MessageDialog:Clone()
	local content = dialog.Frame.ContentFrame.Content
	dialog.Frame.TitleFrame.Title.Text = title
	content.Text = text

	local size =
		TextService:GetTextSize(
		text,
		content.TextSize,
		content.Font,
		Vector2.new(dialog.Frame.AbsoluteSize.X - PADDING * 2, math.huge)
	)
	local frameSize = dialog.Frame.Size

	dialog.Frame.Size = UDim2.new(frameSize.X.Scale, frameSize.X.Offset, 0, size.Y + PADDING * 4 + 100)

	local handle = {
		dialog = dialog,
		close = MessageOverlay.close,
		onAction = MessageOverlay.onAction,
		onClose = function()
		end
	}

	local function onClick()
		handle:onAction()
	end

	dialog.Frame.CloseButton.MouseButton1Click:Connect(onClick)
	dialog.Enabled = true
	dialog.Parent = MessageDialog.Parent

	return handle
end

function MessageOverlay.close(handle)
	handle.dialog:Destroy()
	handle:onClose()
end

function MessageOverlay.onAction(handle)
	handle:close()
end

return MessageOverlay
