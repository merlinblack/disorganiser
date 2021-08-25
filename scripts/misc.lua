
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

function growRect(rect, amount)
  amount = amount or 1
  return { rect[1] - amount, rect[2] - amount, rect[3] + amount, rect[4] + amount}
end

function shrinkRect(rect, amount)
  amount = amount or 1
  return growRect(rect, -amount)
end

yield = coroutine.yield

function wait(ms)
	local finish = app.ticks + ms
	while app.ticks < finish do
		yield()
	end
end

