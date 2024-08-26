local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local SliderTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("SliderTemplate")
local SlidersFrame = Player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Config"):WaitForChild("Sliders")

local Signal = require(ReplicatedStorage.Packages.Signal)

local function lerp(x: number, a: number, b: number)
	return a + x * (b - a)
end

local function inverseLerp(x: number, a: number, b: number)
	return (x - a) / (b - a)
end

local function round(x: number, increment: number)
	return math.round(x / increment) * increment
end

local Slider = {}
Slider.__index = Slider

export type Slider = {
	Name: string,
	Min: number,
	Max: number,
	Value: number,
	Increment: number,
	Updated: typeof(Signal.new()),
	Frame: typeof(SliderTemplate),
}

function Slider.new(name, value, min, max, increment): Slider
	local self = setmetatable({}, Slider)

	self.Name = name
	self.Min = min
	self.Max = max
	self.Value = value
	self.Increment = increment
	self.Updated = Signal.new()
	self.Frame = SliderTemplate:Clone()

	self:Init()

	return self
end

function Slider.Init(self: Slider)
	local slider = self.Frame
	slider.Name = self.Name

	local sliderFrame = slider.SliderFrame
	local cursor = sliderFrame.Cursor

	slider.SliderText.Text = self.Name
	slider.Min.Text = tostring(self.Min)
	slider.Max.Text = tostring(self.Max)
	cursor.Position = UDim2.new(inverseLerp(self.Value, self.Min, self.Max), 0, 0.5, 0)
	slider.SliderBox.Text = tostring(self.Value)
	slider.Parent = SlidersFrame

	local dragDetector = cursor.UIDragDetector
	self.Increment = self.Increment or (self.Max - self.Min) / 100

	dragDetector.DragStyle = Enum.UIDragDetectorDragStyle.Scriptable
	dragDetector:SetDragStyleFunction(function(pos: Vector2)
		local cursorX = ((pos - sliderFrame.AbsolutePosition) / sliderFrame.AbsoluteSize).X
		local roundedValue =
			math.clamp(round(lerp(cursorX, self.Min, self.Max), self.Increment :: number), self.Min, self.Max)

		cursor.Position = UDim2.new(inverseLerp(roundedValue, self.Min, self.Max), 0, 0.5, 0)

		self.Value = roundedValue
		slider.SliderBox.Text = ("%.2f"):format(roundedValue):gsub("%.0+$", "")
		self.Updated:Fire()

		return nil
	end)

	slider.SliderBox.FocusLost:Connect(function()
		local value = tonumber(slider.SliderBox.Text)
		if value then
			self.Value = math.clamp(value, self.Min, self.Max)
			cursor.Position = UDim2.new(inverseLerp(self.Value, self.Min, self.Max), 0, 0.5, 0)
			self.Updated:Fire()
		end
	end)
end

return Slider
