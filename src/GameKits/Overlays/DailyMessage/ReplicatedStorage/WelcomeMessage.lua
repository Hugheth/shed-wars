local WelcomeDialog =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("WelcomeDialog", 10) or
	error("WelcomeMessage couldn't start because WelcomeDialog is missing from StarterGui")
local WelcomeMessage = {}

function WelcomeMessage.onClose()
	-- Add code here or replace the function to add your own behaviour for this event
end

function WelcomeMessage.show(messages)
	WelcomeDialog.Frame.ContentFrame.Content.Text = messages[math.random(1, #messages)]
	WelcomeDialog.Enabled = true
end

function WelcomeMessage.hide()
	WelcomeDialog.Enabled = false
end

local function handleClose()
	WelcomeMessage.hide()
	WelcomeMessage.onClose()
end
WelcomeDialog.Frame.CloseButton.MouseButton1Click:Connect(handleClose)

return WelcomeMessage
