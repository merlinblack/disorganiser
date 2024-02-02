json = require 'json'
request = require 'http.request'
cqueues = require 'cqueues'

weatherRunningOperations = {}
weather = { valid = false }

function asyncHttpRequest(url)
	local queue = cqueues.new()
	local body, statusCode

	queue:wrap(function()
		print ('requesting ' .. url)
		local start = app.ticks

		req = request.new_from_uri(url)
		local headers, stream = req:go(10)

		if headers == nil then
			print( 'failed to retrieve ' .. url .. ' ' .. tostring(stream) )
			body, statusCode = nil, '500'
			return
		end

		local err
		body, err = stream:get_body_as_string()

		if not body and err then
			print('failed to read response stream: ' .. tostring(err))
			body, statusCode = nil, '500'
			return
		end

		local duration = app.ticks - start

		print( 'retrieved ' .. url .. ' in ' .. duration .. 'ms')
		print(headers:get(':status') == '200')

		statusCode = headers:get(':status')

	end)

	while not queue:empty() do
		queue:step(0.1)
		yield()
	end

	return body, statusCode
end

function readLocalWeather()

	if weatherRunningOperations.last20 ~= nil then
		while weatherRunningOperations.last20 ~= nil do
			wait(100)
		end
		return
	end

	weatherRunningOperations.last20 = true

	local data, status = asyncHttpRequest('http://' .. ipaddr.octavo .. '/api/weather')

	if status == '200' then
		weatherData = json.decode(data)
		weather = {
			valid = true,
			temperature = string.format("%.2f", weatherData[1].temperature),
			pressure =    string.format("%.2f", weatherData[1].pressure),
			humidity =    string.format("%.2f", weatherData[1].humidity)
		}
	else
		if fileReadable('/tmp/weather.lua') then
			dofile('/tmp/weather.lua')
			weather.valid = false
		else
			weather = {
				valid = false,
				temperature = '',
				pressure = '',
				humidity = ''
			}
		end
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

	local data, status = asyncHttpRequest('http://' .. ipaddr.octavo .. '/api/weathertrends')

	if status == '200' then
		weatherTrendsData = json.decode(data)
	else
		weatherTrendsData = nil
	end

	weatherRunningOperations.trends = nil

end

function readLocalWeatherSummary(hours)

	local hours = hours or 24

	if weatherRunningOperations.summary ~= nil then
		while weatherRunningOperations.summary ~= nil do
			wait(100)
		end
		return
	end

	weatherRunningOperations.summary = true

	local data, status = asyncHttpRequest('http://' .. ipaddr.octavo .. '/api/weathersummary?hours=' .. hours)

	if status == '200' then
		weatherSummaryData = json.decode(data)
		-- Deal with odd behavour on macmini
		weatherSummaryData.__array = nil
	else
		weatherSummaryData = nil
	end

	weatherRunningOperations.summary = nil

end