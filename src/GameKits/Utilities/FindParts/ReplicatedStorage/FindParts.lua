local function findParts(root, name)
	if typeof(root) == "table" then
		local output = {}
		for _, rootPart in ipairs(root) do
			local parts = findParts(rootPart, name)
			for _, part in ipairs(parts) do
				table.insert(output, part)
			end
		end
		return output
	end
	local parts = {}
	for _, object in ipairs(root:GetDescendants()) do
		if not name or object.Name == name then
			table.insert(parts, object)
		end
	end
	return parts
end

return findParts
