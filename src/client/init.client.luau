--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local NoiseLabel = Player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Config"):WaitForChild("Noise")

local Slider = require(ReplicatedStorage.Shared.Slider)
local VisualizeNoise = require(ReplicatedStorage.Shared.VisualizeNoise)

local WIDTH, HEIGHT = 250, 250
local CENTER = Vector2.new((WIDTH + 1) / 2, (HEIGHT + 1) / 2)
local SEED = Random.new():NextNumber(1, 100000)

local function falloff(x: number, z: number, sliders: { [string]: Slider.Slider })
	x = math.abs(x - CENTER.X)
	z = math.abs(z - CENTER.Y)
	local value
	if x >= z then
		value = 2 * x / WIDTH
	else
		value = 2 * z / HEIGHT
	end
	local a = sliders.A.Value
	local b = sliders.B.Value
	return value ^ a / (value ^ a + (b - b * value) ^ a)
end

local minHeight = math.huge
local maxHeight = -math.huge
local function noise(x: number, z: number, sliders: { [string]: Slider.Slider })
	local amplitude = 1
	local frequency = 1
	local height = sliders.Cutoff.Value - falloff(x, z, sliders)
	for _ = 1, sliders.Octaves.Value do
		height += math.noise(SEED, x / sliders.Scale.Value * frequency, z / sliders.Scale.Value * frequency) * amplitude
		amplitude *= sliders.Persistence.Value
		frequency *= sliders.Lacunarity.Value
	end
	minHeight = math.min(minHeight, height)
	maxHeight = math.max(maxHeight, height)
	return height
end

local TREE_THRESHOLD, GRASS_THRESHOLD, SAND_THRESHOLD, SHORE_THRESHOLD = 1, 0.28, 0.18, 0.08

local function getColor(value: number, sliders: { [string]: Slider.Slider })
	if value > sliders.TreeThreshold.Value then
		return Color3.fromRGB(0, 200, 0)
	elseif value > sliders.GrassThreshold.Value then
		return Color3.fromRGB(107, 215, 116)
	elseif value > sliders.SandThreshold.Value then
		return Color3.fromRGB(227, 216, 182)
	elseif value > sliders.ShoreThreshold.Value then
		return Color3.fromRGB(133, 171, 243)
	else
		return Color3.fromRGB(87, 132, 215)
	end
end

local function inverseLerp(x: number, a: number, b: number)
	return (x - a) / (b - a)
end

local function _greyscale(value: number)
	value = math.clamp(inverseLerp(value, minHeight, maxHeight), 0, 1)
	return Color3.new(value, value, value)
end

local vis = VisualizeNoise.new(noise, getColor, Vector2.new(WIDTH, HEIGHT), {
	A = Slider.new("A", 3, 0, 10, 0.01),
	B = Slider.new("B", 2.2, 0, 10, 0.01),
	Cutoff = Slider.new("Cutoff", 0, -1, 1, 0.01),
	Scale = Slider.new("Scale", 60, 1, 100, 5),
	TreeThreshold = Slider.new("TreeThreshold", TREE_THRESHOLD, -1, 1, 0.01),
	GrassThreshold = Slider.new("GrassThreshold", GRASS_THRESHOLD, -1, 1, 0.01),
	SandThreshold = Slider.new("SandThreshold", SAND_THRESHOLD, -1, 1, 0.01),
	ShoreThreshold = Slider.new("ShoreThreshold", SHORE_THRESHOLD, -1, 1, 0.01),
	Octaves = Slider.new("Octaves", 2, 1, 10, 1),
	Lacunarity = Slider.new("Lacunarity", 2, 1, 10, 1),
	Persistence = Slider.new("Persistence", 0.5, 0, 1, 0.01),
})
vis.Sliders.A.Frame.Visible = false
vis.Sliders.B.Frame.Visible = false

vis.Image.Parent = NoiseLabel
