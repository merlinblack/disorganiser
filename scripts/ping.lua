
function ping(address)
	local proc <close> = SubProcess()
	proc:set('scripts/alive.sh')
	proc:add(address)
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
