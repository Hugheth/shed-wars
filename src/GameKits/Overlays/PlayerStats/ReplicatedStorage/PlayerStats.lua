local PlayerStats = {}

function PlayerStats.setup(columns, defaultValues)
	PlayerStats.columns = columns
	PlayerStats.defaultValues = defaultValues
end

function PlayerStats.setStat(player, name, value)
	player.leaderstats[name].Value = value
end

function PlayerStats.getStat(player, name)
	return player.leaderstats[name].Value
end

local function onJoin(player)
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

game.Players.PlayerAdded:Connect(onJoin)

return PlayerStats
