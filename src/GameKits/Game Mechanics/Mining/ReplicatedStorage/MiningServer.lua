local RequestMine =
	game.ReplicatedStorage:WaitForChild("RequestMine", 10) or
	error("Teams couldn't start because RequestMine is missing from ReplicatedStorage")

local MiningServer = {}

function MiningServer.onMine(player, part)
	-- Add code here or replace the function to add your own behaviour for this event
end

function MiningServer.setup()
	RequestMine.OnServerInvoke = function(player, part)
		part.Transparency = part.Transparency + 0.2
		if part.Transparency == 1 then
			MiningServer.onMine(player, part)
			part:Destroy()
		end
	end
end

return MiningServer
