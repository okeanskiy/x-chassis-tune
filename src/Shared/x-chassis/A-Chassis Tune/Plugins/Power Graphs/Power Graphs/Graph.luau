--[=[

Docs: https://devforum.roblox.com/t/graph-module-easily-draw-graphs-of-your-data/828982/1

API:

function Graph.new(Frame)
	returns a GraphHandler
	
GraphHandler.Resolution = The number of points it renders
GraphHandler.BaselineZero = Whether the bottom of the graph should start at zero (or at the minimum value)
GraphHandler.Data = The dictionary of data sets
	(Data must be a dictionary of arrays with no holes)
	
function GraphHandler.Theme(ThemeDictionary)
	Updates the Colors of the graph

--]=]

local TextService = game:GetService("TextService")
local screen = script:FindFirstAncestorOfClass("ScreenGui")
local _Tune = require(screen.Car.Value["A-Chassis Tune"])

local Graph = {}

local Theme = {
	Name = "Light";
	
	Background = Color3.fromRGB(240,240,240);
	LightBackground = Color3.fromRGB(255,255,255);
	Text = Color3.fromRGB(0,0,0)
}
local isDark = true

local function getKeyColor(name)
	-- Shoutout to Vocksel for the core of this function
	
	local seed = 0
	for i=1, #name do
		seed = seed + (name:byte(i))
	end
	local rng = Random.new(seed)
	local hue = rng:NextInteger(0,50)/50

	return Color3.fromHSV(hue, isDark and 0.63 or 1, isDark and 0.84 or 0.8)
end


function Graph.new(Frame)
	if not Frame then error("Must give graph a frame") end
	local GraphHandler = {Frame = Frame; Resolution = 75; Colors = {}; LineTypes = {}}
	
	-- Private variables
	local Busy = false
	
	-- Create the GUIs
	local BaseZIndex = GraphHandler.Frame.ZIndex

	local Background = Instance.new("Frame")
	Background.Name = "Background"
	Background.BackgroundColor3 = Theme.Background
	Background.BackgroundTransparency = 1
	Background.BorderSizePixel = 0
	Background.Size = UDim2.new(1,0,1,0)
	Background.ZIndex = BaseZIndex+1
	Background.Parent = GraphHandler.Frame

	local MarkerBG = Instance.new("Frame")
	MarkerBG.Name = "MarkerBackground"
	MarkerBG.Size = UDim2.new(0.1,0,1,0)
	MarkerBG.BackgroundColor3 = Color3.new(0,0,0)
	MarkerBG.BackgroundTransparency = .8
	MarkerBG.BorderSizePixel = 0
	MarkerBG.ZIndex = BaseZIndex+2
	MarkerBG.Parent = GraphHandler.Frame
	
	local XMarkerBG = Instance.new("Frame")
	XMarkerBG.Name = "MarkerBackground"
	XMarkerBG.Size = UDim2.new(0.9,0,0.15,0)
	XMarkerBG.Position = UDim2.new(.1,0,0.85,0)
	XMarkerBG.BackgroundColor3 = Color3.new(0,0,0)
	XMarkerBG.BackgroundTransparency = .8
	XMarkerBG.BorderSizePixel = 0
	XMarkerBG.ZIndex = BaseZIndex+2
	XMarkerBG.Parent = GraphHandler.Frame

	local YMarkers = Instance.new("Frame")
	YMarkers.Name = "Markers"
	YMarkers.Size = UDim2.new(0.1,0,0.75,0)
	YMarkers.Position = UDim2.new(0,0,0.1,0)
	YMarkers.BackgroundTransparency = 1
	YMarkers.BorderSizePixel = 0
	YMarkers.ZIndex = BaseZIndex+2
	YMarkers.Parent = GraphHandler.Frame
	
	local XMarkers = Instance.new("Frame")
	XMarkers.Name = "XMarkers"
	XMarkers.Size = UDim2.new(0.9,0,0.15,0)
	XMarkers.Position = UDim2.new(.1,0,0.85,0)
	XMarkers.BackgroundTransparency = 1
	XMarkers.BorderSizePixel = 0
	XMarkers.ZIndex = BaseZIndex+2
	XMarkers.Parent = GraphHandler.Frame

	local GraphingFrame = Instance.new("Frame")
	GraphingFrame.Name = "GraphingFrame"
	GraphingFrame.Size = UDim2.new(0.9,0,0.75,0)
	GraphingFrame.Position = UDim2.new(0.1,0,0.1,0)
	GraphingFrame.BorderSizePixel = 0
	GraphingFrame.BackgroundTransparency = 1
	GraphingFrame.ZIndex = BaseZIndex+2
	GraphingFrame.Parent = GraphHandler.Frame
	
	local GridMarks = GraphingFrame:Clone()
	GridMarks.Name = "GridMarks"
	GridMarks.Parent = GraphHandler.Frame
	
	local KeyNames = Instance.new("Frame")
	KeyNames.Name = "KeyNames"
	KeyNames.Size = UDim2.new(1,0,0.1,0)
	KeyNames.Position = UDim2.new(0,0,0,0)
	KeyNames.BackgroundColor3 = Color3.new(0,0,0)
	KeyNames.BackgroundTransparency = .8
	KeyNames.BorderSizePixel = 0
	KeyNames.BorderSizePixel = 0
	KeyNames.ZIndex = BaseZIndex+2
	KeyNames.Parent = GraphHandler.Frame
	
	-- Rerender if the frame changes size since our lines will be all wonky
	GraphHandler.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local Size = GraphHandler.Frame.AbsoluteSize
		wait(0.04)
		if Size == GraphHandler.Frame.AbsoluteSize then
			GraphHandler.Render()
		end
	end)
	
	function GraphHandler.Theme(newTheme)
		wait()
		-- Make sure we have latest theme data
		Theme = {
			Name = newTheme.Name or "Dark";

			Background = newTheme.Background or Color3.fromRGB(46,46,46);
			LightBackground = newTheme.LightBackground or Color3.fromRGB(70,70,70);
			Text = newTheme.Text or Color3.fromRGB(220,220,230);
		}
		
		-- Update GUIs
		Background.BackgroundColor3 = Theme.Background
		MarkerBG.BackgroundColor3 = Theme.LightBackground
		KeyNames.BackgroundColor3 = Theme.LightBackground
		
		-- Redraw graph with new colors
		GraphHandler.Render()
	end
	
	function GraphHandler.Render()
		-- Validate we have stuff to render
		if not GraphHandler.Frame or not GraphHandler.Data or not GraphHandler.Resolution then
			return
		end
		
		while Busy do wait(0.1) end
		Busy = true
		
		-- Clear old graph values
		YMarkers:ClearAllChildren()
		XMarkers:ClearAllChildren()
		GraphingFrame:ClearAllChildren()
		GridMarks:ClearAllChildren()
		KeyNames:ClearAllChildren()
		
		BaseZIndex = GraphHandler.Frame.ZIndex
		
		Background.ZIndex = BaseZIndex+1
		MarkerBG.ZIndex = BaseZIndex+2
		YMarkers.ZIndex = BaseZIndex+2
		XMarkers.ZIndex = BaseZIndex+2
		GraphingFrame.ZIndex = BaseZIndex+2
		KeyNames.ZIndex = BaseZIndex+2
		
		local KeyLayout = Instance.new("UIListLayout")
		KeyLayout.FillDirection = Enum.FillDirection.Horizontal
		KeyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		KeyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		KeyLayout.Padding = UDim.new(0.01,0)
		KeyLayout.Parent = KeyNames
		
		local Max, Min = -math.huge,math.huge
		local Range
		local XMax, XMin = -math.huge,math.huge
		local XRange
		
		-- Calculate our range of values

		for Key, Set in pairs(GraphHandler.Data) do
			local SetAmount = #Set
			
			for i, v in pairs(Set) do
				XMin = math.min(XMin, i)
				XMax = math.max(XMax, i)
			end
			XRange = XMax - XMin

			for i=1,SetAmount, math.ceil(SetAmount/GraphHandler.Resolution) do
				local SortedChunk = {}
				for x=i,i+math.ceil(SetAmount/GraphHandler.Resolution) do
					SortedChunk[#SortedChunk+1] = Set[x]
				end
				table.sort(SortedChunk)

				local Value = SortedChunk[math.round(#SortedChunk*0.55)]
				if not Value then continue end

				-- Record for our range calc
				Min = math.min(Min, Value)
				Max = math.max(Max, Value)
			end
		end
		
		if GraphHandler.BaselineZero then
			Min = 0
		end

		Range = Max-Min
		
		-- Mark our Y axis values along the derived range
		
		for y=0,1,0.2 do
			local Marker = Instance.new("TextLabel")
			Marker.Name = y
			Marker.Size = UDim2.new(.92,0,0.08,0)
			Marker.AnchorPoint = Vector2.new(0,0.5)
			Marker.Position = UDim2.new(0,0,1 - (y),0)
			Marker.Text = math.round(0 + (math.round((Max+50)/100)*100*y))
			Marker.TextXAlignment = Enum.TextXAlignment.Right

			Marker.TextColor3 = Color3.new(1,1,1)
			Marker.Font = Enum.Font.SourceSansSemibold
			Marker.BackgroundTransparency = 1
			Marker.TextSize = (GraphHandler.Frame.AbsoluteSize.X*0.03)
			Marker.ZIndex = BaseZIndex+3
			Marker.Parent = YMarkers
			
			if 0 < y and y < 1 then
				local GridMark = Instance.new("Frame")
				GridMark.Name = y
				GridMark.Size = UDim2.new(1, 0, 0, 1)
				GridMark.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				GridMark.BackgroundTransparency = .6
				GridMark.BorderSizePixel = 0
				GridMark.ZIndex = BaseZIndex+4
				GridMark.AnchorPoint = Vector2.new(0, .5)
				GridMark.Position = UDim2.new(0, 0, 1-y, 0)
				GridMark.Parent = GridMarks
			end
		end
		
		for x=0,1,1/math.round(_Tune.Redline/1000+.49) do
			local Marker = Instance.new("TextLabel")
			Marker.Name = x
			Marker.Size = UDim2.new(1,0,0.08,0)
			Marker.AnchorPoint = Vector2.new(.5,0)
			Marker.Position = UDim2.new(x,0,.3,0)
			Marker.Text = math.round(0 + (XMax*(x))/10)*10
			Marker.TextXAlignment = Enum.TextXAlignment.Center

			Marker.TextColor3 = Color3.new(1,1,1)
			Marker.Font = Enum.Font.SourceSans
			Marker.BackgroundTransparency = 1
			Marker.TextSize = (GraphHandler.Frame.AbsoluteSize.X*0.03)
			Marker.ZIndex = BaseZIndex+3
			Marker.Parent = XMarkers
			if 0 < x and x < 1 then
				local GridMark = Instance.new("Frame")
				GridMark.Name = x
				GridMark.Size = UDim2.new(0,1, 1,0)
				GridMark.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				GridMark.BackgroundTransparency = .6
				GridMark.ZIndex = BaseZIndex+4
				GridMark.BorderSizePixel = 0
				GridMark.AnchorPoint = Vector2.new(.5,0)
				GridMark.Position = UDim2.new(x, 0, 0, 0)
				GridMark.Parent = GridMarks
			end
		end
		
		-- Draw the graph at this range
		local KeyColors = {}
		for Key, Set in pairs(GraphHandler.Data) do
			-- Designate a color for this dataset
			KeyColors[Key] = getKeyColor(Key)
			
			local TextSize = GraphHandler.Frame.AbsoluteSize.Y*0.08
			local Size = TextService:GetTextSize(Key, TextSize, Enum.Font.SourceSansSemibold, KeyNames.AbsoluteSize)
			
			-- Graph the set

			local SetAmount = #Set
			local LastPoint

			--print("  "..Key, Set)

			for i=1,SetAmount, math.ceil(SetAmount/GraphHandler.Resolution) do

				local SortedChunk = {}
				for x=i,i+math.ceil(SetAmount/GraphHandler.Resolution) do
					SortedChunk[#SortedChunk+1] = Set[x]
				end
				table.sort(SortedChunk)

				local Value = SortedChunk[math.round(#SortedChunk*0.55)]
				if not Value then continue end

				-- Create the point
				local Point = Instance.new("ImageLabel")
				Point.Name = Key..i
				Point.Position = UDim2.new((i/(math.round(0 + (XMax)/1000)*1000)),0, 1 - ((Value/(math.round((Max+50)/100)*100))),0)
				Point.BorderSizePixel = 0
				Point.AnchorPoint = Vector2.new(0.5,0.5)
				Point.SizeConstraint = Enum.SizeConstraint.RelativeXX
				Point.Size = UDim2.new(math.clamp(0.5/GraphHandler.Resolution, 0.003,0.016),0,math.clamp(0.5/GraphHandler.Resolution, 0.003,0.016),0)

				Point.ImageColor3 = KeyColors[Key]
				Point.BorderSizePixel = 0
				Point.BackgroundTransparency = 1
				Point.Image = "rbxassetid://200182847"
				Point.ZIndex = BaseZIndex+5

				-- Create the line
				if LastPoint then
					local Connector = Instance.new("Frame")
					Connector.Name = Key..i.."-"..i-1
					Connector.BackgroundColor3 = GraphHandler.Colors[Key] or KeyColors[Key]
					Connector.BorderSizePixel = 0
					Connector.SizeConstraint = Enum.SizeConstraint.RelativeXX
					Connector.AnchorPoint = Vector2.new(0.5, 0.5)
					Connector.ZIndex = BaseZIndex+5

					local Size = GraphingFrame.AbsoluteSize
					local startX, startY = Point.Position.X.Scale*Size.X, Point.Position.Y.Scale*Size.Y
					local endX, endY = LastPoint.Position.X.Scale*Size.X, LastPoint.Position.Y.Scale*Size.Y

					local Distance = (Vector2.new(startX, startY) - Vector2.new(endX, endY)).Magnitude

					Connector.Size = UDim2.new(0, (Distance+2)*(GraphHandler.LineTypes[Key] or 0), 0, 2)
					Connector.Position = UDim2.new(0, (startX + endX) / 2, 0, (startY + endY) / 2)
					Connector.Rotation = math.atan2(endY - startY, endX - startX) * (180 / math.pi)

					Connector.Parent = GraphingFrame
				end

				LastPoint = Point

			end

		end
		
		Busy = false
	end
	
	return setmetatable({}, {
		__index = function(t,Key)
			return GraphHandler[Key]
		end;
		__newindex = function(t, Key, Value)
			if Key == "Data" and type(Value) == "table" then
				GraphHandler.Data = Value
				GraphHandler.Render()
			elseif Key == "Resolution" and type(Value) == "number" then
				GraphHandler.Resolution = math.clamp(Value, 3, 500)
				GraphHandler.Render()
			elseif Key == "BaselineZero" and type(Value) == "boolean" then
				GraphHandler.BaselineZero = Value
				GraphHandler.Render()
			elseif Key == "Colors" and type(Value) == "table" then
				GraphHandler.Colors = Value
				GraphHandler.Render()
			elseif Key == "LineTypes" and type(Value) == "table" then
				GraphHandler.LineTypes = Value
				GraphHandler.Render()
			end
		end;
	})
	
end


return Graph
