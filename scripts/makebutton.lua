function makeButton(renderList, textcolor, rect, text)
	local color = Color(0,0,0,0xa0)
	local rectangle <close> = Rectangle(color, true, rect)
	renderList:add(rectangle)

	local font <close> = Font('media/mono.ttf',24)
	local text <close> = app.renderer:textureFromText(font, text, textcolor)
	local rectangle <close> = Rectangle(
		text,
		rect[1]+((rect[3]//2)-(text.width//2)),
		rect[2]+((rect[4]//2)-(text.height//2))
	)
	renderList:add(rectangle)
	local rectangle <close> = Rectangle( textcolor, false, rect )
	renderList:add(rectangle)
end
