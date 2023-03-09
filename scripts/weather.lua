json = require('json')

weatherRunningOperations = {}
weather = { valid = false }

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
		--print('waiting for ' .. url)
		wait(250)
	end

	local duration = app.ticks - start

	print( 'retrieved ' .. url .. ' in ' .. duration .. 'ms')

	return get:join()
end

function readLocalWeather()

	if weatherRunningOperations.last20 ~= nil then
		while weatherRunningOperations.last20 ~= nil do
			wait(100)
		end
		return
	end

	weatherRunningOperations.last20 = true

	local data, status = asyncHttpRequest('http://octavo.local/api/weather')

	if status == 200 then
		weatherData = json.decode(data)
		weather = {
			valid = true,
			temperature = string.format("%.2f", weatherData[1].temperature),
			pressure =    string.format("%.2f", weatherData[1].pressure),
			humidity =    string.format("%.2f", weatherData[1].humidity)
		}
	else
		weather = {
			valid = false,
			temperature = '',
			pressure = '',
			humidity = ''
		}
	end

	weatherRunningOperations.last20 = nil

end

function readLocalWeatherTrends()

	if weatherRunningOperations.trends ~= nil then
		while weatherRunningOperations.trends ~= nil do
			wait(100)
		end
		return
	end

	weatherRunningOperations.trends = true

	local data, status = asyncHttpRequest('http://octavo.local/api/weathertrends')

	if status == 200 then
		weatherTrendsData = json.decode(data)
	else
		weatherTrendsData = nil
	end

	weatherRunningOperations.trends = nil

end

function readLocalWeatherSummary()

	if weatherRunningOperations.summary ~= nil then
		while weatherRunningOperations.summary ~= nil do
			wait(100)
		end
		return
	end

	weatherRunningOperations.summary = true

	local data, status = asyncHttpRequest('http://octavo.local/api/weathersummary')

	if status == 200 then
		weatherSummaryData = json.decode(data)
	else
		weatherSummaryData = nil
	end

	weatherRunningOperations.summary = nil

end