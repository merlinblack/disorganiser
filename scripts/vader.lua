require 'suspend'
-- Test is Vader is running every 30 secs

vaderAlive = true

function isVaderAlive()
	local proc <close> = ProcessReader()
	proc:set('scripts/alive.sh')
	proc:add(vader.ipaddr)
	proc:open()
	local more = true
	local results
	while more do
		more, results = proc:read()
		results = string.gsub(results, '^%s*(.-)%s*$', '%1')
		if results ~= '' then
			if results == 'alive' then
				return true
			end
		end
		yield()
	end
	return false
end

function checkVaderTask()
	while true do
		vaderAlive = isVaderAlive()
		if not vaderAlive then
			suspend:activate()
		end
		wait(30000)
	end
end

addTask(checkVaderTask,'vaderCheck')