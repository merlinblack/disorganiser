http = require('socket.http')
json = require('json')

function readLocalWeather()
	data, status = http.request('http://192.168.1.105/api/weather')
	if status == 200 then
		last20 = json.decode(data)
		weather = {
			temperature = string.format("%.2f", last20[1].temperature),
			pressure =    string.format("%.2f", last20[1].pressure),
			humidity =    string.format("%.2f", last20[1].humidity)
		}
	else
		weather = {
			temperature = '',
			pressure = '',
			humidity = ''
		}
	end
end