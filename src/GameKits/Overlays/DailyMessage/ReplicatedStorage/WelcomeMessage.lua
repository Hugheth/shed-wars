local WelcomeDialog =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("WelcomeDialog", 10) or
	error("WelcomeMessage couldn't start because WelcomeDialog is missing from StarterGui")
local WelcomeMessage = {}

function WelcomeMessage.show(messages)
	WelcomeDialog.Frame.ContentFrame.Content.Text = messages[math.random(1, #messages)]
	WelcomeDialog.Enabled = true
end

function WelcomeMessage.hide()
	WelcomeDialog.Enabled = false
end

local function handleClose()
	WelcomeMessage.hide()
	if WelcomeMessage.onClose then
		WelcomeMessage.onClose()
	end
end
WelcomeDialog.Frame.CloseButton.MouseButton1Click:Connect(handleClose)

return WelcomeMessage
