--!strict
local Slider = require(script.Parent.Slider)

local VisualizeNoise = {}
VisualizeNoise.__index = VisualizeNoise

type Slider = Slider.Slider
export type VisualizeNoise = {
	Image: EditableImage,
	Sliders: { [string]: Slider },
	NoiseFn: NoiseFn,
	ColorFn: ColorFn,

	Update: (self: VisualizeNoise) -> (),
}
export type NoiseFn = (number, number, { [string]: Slider }) -> number
export type ColorFn = (value: number, { [string]: Slider }) -> Color3

function VisualizeNoise.new(
	noiseFn: NoiseFn,
	colorFn: ColorFn,
	size: Vector2,
	sliders: { [string]: Slider }
): VisualizeNoise
	local self = (setmetatable({}, VisualizeNoise) :: any) :: VisualizeNoise
	self.Image = Instance.new("EditableImage")
	self.Image.Size = size
	self.Sliders = sliders
	self.NoiseFn = noiseFn
	self.ColorFn = colorFn

	for _, slider in sliders do
		slider.Updated:Connect(function()
			self:Update()
		end)
	end

	self:Update()

	return self
end

function VisualizeNoise.Update(self: VisualizeNoise)
	local width, height = self.Image.Size.X, self.Image.Size.Y
	local pixels = table.create(width * height * 4)
	local noise = self.NoiseFn
	local getColor = self.ColorFn
	local sliders = self.Sliders

	for x = 1, width do
		for y = 1, height do
			local color = getColor(noise(x, y, sliders), sliders)
			table.insert(pixels, color.R)
			table.insert(pixels, color.G)
			table.insert(pixels, color.B)
			table.insert(pixels, 1)
		end
	end
	self.Image:WritePixels(Vector2.zero, self.Image.Size, pixels)
end

return VisualizeNoise
