local LobbyDialog =
	game.Players.LocalPlayer.PlayerGui:WaitForChild("LobbyDialog", 10) or
	error("LobbyClient couldn't start because LobbyDialog is missing from StarterGui")
local RequestChangeReadyStatus =
	game.ReplicatedStorage:WaitForChild("RequestChangeReadyStatus", 10) or
	error("LobbyClient couldn't start because RequestChangeReadyStatus is missing from ReplicatedStorage")
local LobbyStatus =
	game.ReplicatedStorage:WaitForChild("LobbyStatus", 10) or
	error("LobbyClient couldn't start because LobbyStatus is missing from ReplicatedStorage")

local LobbyClient = {
	isReady = false,
	inGame = LobbyStatus.Value == "InGame"
}

function LobbyClient.onGameStart(playerInGame)
	-- Add code here or replace the function to add your own behaviour for this event
end

function LobbyClient.onGameEnd()
	-- Add code here or replace the function to add your own behaviour for this event
end

function LobbyClient.showDialog()
	if LobbyClient.inGame then
		return
	end
	LobbyClient.updateLobbyStatus()
	LobbyDialog.Enabled = true
end

function LobbyClient.updateLobbyStatus()
	local status = LobbyStatus.Value
	if status == "InGame" and not LobbyClient.inGame then
		LobbyClient.startGame()
	end
	LobbyDialog.Frame.ContentFrame.Content.Text = status
end

function LobbyClient.startGame()
	LobbyClient.inGame = true
	LobbyClient.hideDialog()
	LobbyClient.onGameStart(LobbyClient.isReady)
end

function LobbyClient.endGame()
	LobbyClient.isReady = false
	LobbyClient.inGame = false
	LobbyClient.onGameEnd()
end

function LobbyClient.hideDialog()
	LobbyDialog.Enabled = false
end

function LobbyClient.setup()
	local function handleReady()
		LobbyClient.isReady = not LobbyClient.isReady
		LobbyDialog.Frame.ReadyButton.Text = LobbyClient.isReady and "Set Not Ready" or "Set Ready"
		RequestChangeReadyStatus:InvokeServer(LobbyClient.isReady)
	end

	LobbyDialog.Frame.ReadyButton.MouseButton1Click:Connect(handleReady)
	LobbyStatus.Changed:Connect(LobbyClient.updateLobbyStatus)

	LobbyClient.updateLobbyStatus()
end

return LobbyClient
