function task()
	wait(1000)

	local rl = RenderList()
	local texture <close> = app.renderer:textureFromFile('media/picture.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = { 0, 0, 800, 480}
	local rectangle <close> = Rectangle(texture, dest, src);
	rl:add(rectangle)
	local btn = { ExitBtn.x1, ExitBtn.y1, ExitBtn.x2-ExitBtn.x1, ExitBtn.y2-ExitBtn.y1}
	local textcolor = Color(0xff,0x45,0x8a,0xff)
	makeButton(rl, textcolor, btn, 'Exit')
	rl:shouldRender()

	app.renderList = rl

	for n=1,5 do
		print(n)
		yield()
	end

	runClock = false
end
