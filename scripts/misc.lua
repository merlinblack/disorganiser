function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function splitByNewline(str)
  lines = {}
  for s in str:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

function pt(t)
    for k,v in pairs(t) do
        print(k,v)
    end
end

yield = coroutine.yield

function wait(ms)
	local finish = app.ticks + ms
	while app.ticks < finish do
		yield()
	end
end

