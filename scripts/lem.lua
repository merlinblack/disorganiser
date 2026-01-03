require 'animation'

function lemwalk()
	local lem =
		Animation(Texture 'media/lemmings.png', dofile 'media/lemmings.lua', dofile 'scripts/lemmings/frames.lua', 10)
	lem:setFrameCycle 'walk_left'
	lem:start()
	for x = app.width + 5, -160, -10 do
		lem:setPosition(x, 400)
		wait(100)
	end
end
