local VitalsServer = {}

function VitalsServer.onJoin(player)
	for _, name in ipairs(VitalsServer.names) do
		local valueTypes = {
			string = "StringValue",
			boolean = "BoolValue",
			number = "NumberValue"
		}
		local defaultValue = VitalsServer.defaultValues[name]
		local valueType = valueTypes[type(defaultValue)]
		local vitalValue = Instance.new(valueType)
		vitalValue.Name = name
		vitalValue.Value = defaultValue
		vitalValue.Parent = player
	end
end

function VitalsServer.setup(names, defaultValues)
	VitalsServer.names = names
	VitalsServer.defaultValues = defaultValues
	game.Players.PlayerAdded:Connect(VitalsServer.onJoin)
end

return VitalsServer