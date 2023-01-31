http = require('socket.http')
json = require('json')

function readLocalWeather()
	data, status = http.request('http://octavo.local/api/weather')
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

function readLocalWeatherTrends()
	data, status = http.request('http://octavo.local/api/weathertrends')
	if status == 200 then
		weatherTrendsData = json.decode(data)
	else
		weatherTrendsData = nil
	end
end

function readLocalWeatherSummary()
	data, status = http.request('http://octavo.local/api/weathersummary')
	if status == 200 then
		weatherSummaryData = json.decode(data)
	else
		weatherSummaryData = nil
	end
end