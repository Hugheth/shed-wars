--[[
	The purpose of this module is to provide examples of a game kit that:
	- Is purely server-side
	- Provides behaviour for each player that joins
	- Provides an API that any other server code can query
]]
local PlayerStats = {}

--[[
	Set up the stats for a player with an array of column names and a map of default values for
	each column.

	Stats can be strings, numbers or booleans, and are displayed in the leaderstats table.
]]
--: string[], {[column: string]: string | bool | number } -> void
function PlayerStats.setup(columns, defaultValues)
	PlayerStats.columns = columns
	PlayerStats.defaultValues = defaultValues
	-- Add a listener to fire when a player connects to the server
	game.Players.PlayerAdded:Connect(PlayerStats._onJoin)
end

-- Sets the stat for a _player_ with a given _name_ and _value_.
--: Player, string -> void
function PlayerStats.setStat(player, name, value)
	player.leaderstats[name].Value = value
end

-- Returns the stat for a _player_ with a given _name_.
--: Player, string -> void
function PlayerStats.getStat(player, name)
	return player.leaderstats[name].Value
end

--[[
	Add stats for a player when it joins the server.
]]
--: Player -> void
function PlayerStats._onJoin(player)
	-- Create a new leaderstats instance for the player
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for _, column in ipairs(PlayerStats.columns) do
		local valueTypes = {
			string = "StringValue",
			boolean = "BoolValue",
			number = "NumberValue"
		}
		local defaultValue = PlayerStats.defaultValues[column]
		local valueType = valueTypes[type(defaultValue)]
		local columnInstance = Instance.new(valueType)
		columnInstance.Name = column
		columnInstance.Value = defaultValue
		columnInstance.Parent = leaderstats
	end
end

return PlayerStats
