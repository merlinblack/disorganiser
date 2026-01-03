--[[

packatlas.lua
-------------

Uses ImageMagik command line utilities to compose an atlas image.

Copyright (c) 2010 Nigel Atkinson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. 

]]
--

local images = {}
local placed = {}

local scaling = 100
local padding = 0

local function getSize(filename)
	local p = io.popen("magick identify -format '%w %h' " .. filename)
	local ret = p:read '*a'
	p:close()
	local split = string.find(ret, ' ')
	return string.sub(ret, 1, split - 1) + 0, string.sub(ret, split + 1) + 0
end

local function getFiles(directory, listfile)
	for file in io.lines(directory .. '/' .. listfile) do
		print(file)
		local image = { x = 0, y = 0, filename = directory .. '/' .. file, name = file }
		image.w, image.h = getSize(image.filename)
		image.w = image.w * scaling // 100
		image.h = image.h * scaling // 100
		table.insert(images, image)
	end
end

local function imageArea(image) return image.w * image.h end

local function compare(a, b)
	return a.h > b.h
	--return imageArea(a) > imageArea(b)
end

local function placeImage(index, x, y)
	local image = images[index]

	image.x = x
	image.y = y

	table.insert(placed, image)
	table.remove(images, index)
end

local function fits(canvas, image)
	print('Check fit:', image.name, image.w, image.h, canvas.w, canvas.h)
	if image.w + padding <= canvas.w and image.h + padding <= canvas.h then
		--print 'Yes'
		return true
	end
	--print 'No'
	return false
end

local function showlists()
	print()
	print 'Remaining List'
	for _, v in pairs(images) do
		print(v.x, v.y, v.w, v.h, v.name)
	end
	print()
	print 'Placed List'
	for _, v in pairs(placed) do
		print(v.x, v.y, v.w, v.h, v.name)
	end
	print()
end

local function fillcanvas(canvas)
	-- Find the bigest image that will fit and place it.
	-- Divide leftover space and call recursively.
	--
	if #images == 0 then return end -- no images left to fit
	if canvas.w <= 0 then return end
	if canvas.h <= 0 then return end

	print('Canvas ', canvas.x, canvas.y, canvas.w, canvas.h)
	for i, v in ipairs(images) do
		if fits(canvas, v) then
			--print( 'Placing image', v.image, 'at', canvas.x, canvas.y )
			placeImage(i, canvas.x, canvas.y)
			-- Horizontal
			local subcanvas =
				{ x = canvas.x + v.w + padding, y = canvas.y, w = canvas.w - v.w - padding, h = v.h + padding }
			fillcanvas(subcanvas)
			-- Vertical
			local subcanvas = { x = canvas.x, y = canvas.y + v.h + padding, w = canvas.w, h = canvas.h - v.h - padding }
			fillcanvas(subcanvas)

			return
		end
	end
end

local function compositePlacedImage(image, gorillaFile, compositeFile)
	print('Compositing image from ' .. image.filename)

	local cmd, desc, from

	if scaling ~= 100 then
		cmd = 'magick ' .. image.filename .. ' -resize ' .. scaling .. '% temp.png'
		os.execute(cmd)
		from = 'temp.png'
	else
		from = image.filename
	end

	cmd = 'magick composite -geometry +' .. image.x .. '+' .. image.y .. ' ' .. from
	cmd = cmd .. ' ' .. compositeFile .. '.png ' .. compositeFile .. '.png'
	os.execute(cmd)

	desc = string.sub(image.name, 1, string.find(image.name, '.png') - 1)
	desc = desc:gsub('-', '_')
	desc = desc .. ' = { ' .. image.x .. ', ' .. image.y
	desc = desc .. ', ' .. image.w .. ', ' .. image.h .. ' },'
	gorillaFile:write(desc .. '\n')
end

local function processPlacedImages(canvas, compositeFile)
	local cmd = 'magick -size ' .. canvas.w .. 'x' .. canvas.h .. ' xc:transparent PNG32:' .. compositeFile .. '.png'
	print(cmd)
	os.execute(cmd)
	local gorillaFile = io.open(compositeFile .. '.lua', 'w+')

	gorillaFile:write 'return {\n'

	for _, v in pairs(placed) do
		compositePlacedImage(v, gorillaFile, compositeFile)
	end

	gorillaFile:write '}\n'

	gorillaFile:close()

	if scaling ~= 100 then os.execute 'rm temp.png' end
end

function MakeAtlas(width, height, directory, compositeFile)
	getFiles(directory, 'imagelist.txt')

	local canvas = {}
	canvas.x = 0
	canvas.y = 0
	canvas.w = width
	canvas.h = height

	table.sort(images, compare)

	fillcanvas(canvas)
	showlists()

	if #images ~= 0 then
		print 'Failed to fit all images.'
	else
		processPlacedImages(canvas, compositeFile)
		print('Fitted all images within a canvas of ' .. canvas.w .. 'x' .. canvas.h)
	end
end
