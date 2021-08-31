localWeatherFile = '/tmp/weather.lua'

function readLocalWeatherFile()
	f = io.open(localWeatherFile,'r')
	if f ~= nil then
		f:close()
		dofile(localWeatherFile)
	else
		weather = {
			temperature = '??.??',
			pressure = '????.??',
			humidity = '??.??'
		}
	end
end