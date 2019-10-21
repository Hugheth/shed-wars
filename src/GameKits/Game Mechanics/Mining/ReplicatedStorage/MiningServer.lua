--[[
	The purpose of this module is to provide examples of a game kit that:
	- Spans the client and the server
	- Uses another "oracle" game kit that takes ownership of a system in Roblox (PlayerRaycaster)
	- Takes a configuration function. This could alternatively be implemented as an overridden default or included in an options table input.
	- Has an active / passive state
]]
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
