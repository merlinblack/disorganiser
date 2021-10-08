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
		self:setDisplayPower(0)
		print('Screen power off')
	
		while not self.shouldWake and not vaderAlive do
			yield()
		end

		print ('Wakey wakey')

		mainScreen:activate()
	end
	addTask(wakeup,'alarm clock')
end

function Suspend:deactivate()
	Screen.deactivate(self)
	function powerOn()
		self:setDisplayPower(1)
	end
	addTask(powerOn,'display on')
end

function Suspend:setDisplayPower(value)
	local proc <close> = ProcessReader()

	proc:set('vcgencmd')
	proc:add('display_power')
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