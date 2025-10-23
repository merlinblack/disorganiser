-- blank screen that powers down the the display when activated
-- and back on when deactivated

require 'gui/screen'
require 'main'

class 'Suspend' (Screen)

function Suspend:mouseClick(time, x, y, button)
	self.shouldWake = true
end

function Suspend:activate()
	if self:isActive() then
		return
	end
	Screen.activate(self)
	self.shouldWake = false
	function wakeup()
		self:setDisplayPower('--off')
		print('Screen power off')
		vaderAlive = false

		while not self.shouldWake and not vaderAlive do
			yield()
		end

		print ('Wakey wakey')

		self:activatePrevious()
	end
	addTask(wakeup,'alarm clock')
end

function Suspend:deactivate()
	Screen.deactivate(self)
	function powerOn()
		self:setDisplayPower('--on')
		app.renderList:shouldRender()
	end
	addTask(powerOn,'display on')
end

function Suspend:setDisplayPower(value)
	local proc <close> = SubProcess()

	if app.displayName == nil then
		app.displayName = 'HDMI-1'
	end

	local program = 'xrandr'
	if app.displayType == 'wayland' then
		program = 'wlr-randr'
	end

	proc:set(program)
	proc:add('--output')
	proc:add(app.displayName)
	proc:add(value)
	proc:open()
	local more = true
	while more do
		more, result = proc:read()
		yield()
	end
	print(result)
end

suspend = Suspend()
