local DebugOutputFolder = workspace.DebugOutput :: Folder

local function inferType(value)
	local valueType = typeof(value)
	if valueType == "number" then
		return "NumberValue"
	elseif valueType == "string" then
		return "StringValue"
	elseif valueType == "boolean" then
		return "BoolValue"
	elseif valueType == "Instance" then
		return "ObjectValue"
	else
		error("Unsupported type: " .. valueType)
	end
end

local DebugOutput = {}

function DebugOutput.setValue(key, value)
	local valueObject = DebugOutputFolder:FindFirstChild(key)
	if not valueObject then
		valueObject = Instance.new(inferType(value))
		valueObject.Name = key
		valueObject.Parent = DebugOutputFolder
	end

	valueObject.Value = value
end

function DebugOutput.getValue(key)
	local valueObject = DebugOutputFolder:FindFirstChild(key)
	if valueObject then
		return valueObject.Value
	end
end

return DebugOutput
