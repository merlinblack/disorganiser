http = require('socket.http')
json = require('json')

function asyncHttpRequest(url)
	print ('requesting ' .. url)
	local start = app.ticks
	local get = lanes.gen('package,string,math,table',
		function(url)
			http = require('socket.http')
			return http.request(url)
		end
	)(url)

	while get.status ~= "done" and get.status ~= "error" do
		print('waiting for ' .. url)
		wait(10)
	end

	local duration = app.ticks - start

	print( 'retrieved ' .. url .. ' in ' .. duration .. 'ms')

	return get:join()
end

function readLocalWeather()

	if currentyGettingLocalWeather ~= nil then
		while currentyGettingLocalWeather ~= nil do
			wait(100)
		end
		return
	end

	currentyGettingLocalWeather = true

	data, status = asyncHttpRequest('http://octavo.local/api/weather')

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

	currentyGettingLocalWeather = nil

end

function readLocalWeatherTrends()

	data, status = asyncHttpRequest('http://octavo.local/api/weathertrends')

	if status == 200 then
		weatherTrendsData = json.decode(data)
	else
		weatherTrendsData = nil
	end

end

function readLocalWeatherSummary()

	data, status = asyncHttpRequest('http://octavo.local/api/weathersummary')

	if status == 200 then
		weatherSummaryData = json.decode(data)
	else
		weatherSummaryData = nil
	end

end