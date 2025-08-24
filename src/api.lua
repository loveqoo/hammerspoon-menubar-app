-- HTTP 요청을 위한 API 모듈
---@diagnostic disable: undefined-global
local hs = hs -- Hammerspoon 전역 변수
local M = {}

-- 설정 파일 로드
local config = require("config")

-- 모듈 초기화
function M.init()
	-- config 파일 기반으로 API 설정 구성
	M.apis = {
		-- 날씨 API (설정 가능한 지역)
		{
			name = "weather",
			url = string.format(
				"%s?q=%s,%s&appid=%s&units=%s",
				config.api.base_url,
				config.weather.city,
				config.weather.country,
				config.api.openweather_key,
				config.weather.units
			),
			method = "GET",
			headers = {},
			timeout = config.api.timeout_sec,
			parser = function(data)
				local weather = data.weather[1]
				return {
					temperature = math.floor(data.main.temp + 0.5) .. "°C",
					feels_like = math.floor(data.main.feels_like + 0.5) .. "°C",
					humidity = data.main.humidity .. "%",
					description = weather.description,
					icon = weather.icon,
					wind_speed = data.wind.speed .. " m/s",
					pressure = data.main.pressure .. " hPa",
					city = data.name,
					country = data.sys.country,
					timestamp = os.date("%H:%M", os.time()),
				}
			end,
		},
	}
end

-- 설정 유효성 검사
function M.validateConfig()
	if not config.api.openweather_key or config.api.openweather_key == "YOUR_API_KEY" then
		return false, "OpenWeatherMap API 키가 설정되지 않았습니다. config.lua 파일을 확인하세요."
	end
	return true, nil
end

-- 디버그 로깅
local function debugLog(message)
	if config.debug and config.debug.enabled then
		print("[Weather API Debug] " .. message)
	end
end

-- HTTP 요청 실행
function M.makeRequest(apiConfig, callback)
	local url = apiConfig.url
	local headers = apiConfig.headers or {}

	debugLog("Making request to: " .. url)

	-- Hammerspoon HTTP 요청 (올바른 API 사용)
	hs.http.asyncGet(url, headers, function(status, body)
		debugLog("Response status: " .. tostring(status))

		if status == 200 then
			if config.debug and config.debug.log_api_responses then
				debugLog("Response body: " .. (body or "nil"))
			end

			local success, result = pcall(function()
				local data = hs.json.decode(body)
				if apiConfig.parser then
					return apiConfig.parser(data)
				end
				return data
			end)

			if success then
				debugLog("Successfully parsed response")
				callback(result, nil)
			else
				local errorMsg = "응답 파싱 실패: " .. tostring(result)
				debugLog("Error: " .. errorMsg)
				callback(nil, errorMsg)
			end
		else
			local errorMsg = "HTTP " .. tostring(status) .. ": " .. (body or "알 수 없는 오류")
			debugLog("Error: " .. errorMsg)
			callback(nil, errorMsg)
		end
	end)
end

-- 설정된 모든 API에서 데이터 가져오기
function M.fetchAllApis(callback)
	-- 설정 유효성 검사
	local isValid, errorMsg = M.validateConfig()
	if not isValid then
		callback({}, { weather = errorMsg })
		return
	end

	local results = {}
	local errors = {}
	local completed = 0
	local total = #M.apis

	if total == 0 then
		callback({}, nil)
		return
	end

	debugLog("Fetching data from " .. total .. " APIs")

	for _, apiConfig in ipairs(M.apis) do
		M.makeRequest(apiConfig, function(data, error)
			completed = completed + 1

			if error then
				errors[apiConfig.name] = error
			else
				results[apiConfig.name] = data
			end

			if completed == total then
				local hasErrors = next(errors) ~= nil
				debugLog("All API calls completed. Errors: " .. (hasErrors and "yes" or "no"))
				if hasErrors then
					callback(results, errors)
				else
					callback(results, nil)
				end
			end
		end)
	end
end

-- 새 API 설정 추가
function M.addApi(name, url, _config)
	local apiConfig = {
		name = name,
		url = url,
		method = _config.method or "GET",
		headers = _config.headers or {},
		timeout = _config.timeout_sec or 10,
		parser = _config.parser,
	}

	table.insert(M.apis, apiConfig)
end

-- API 설정 제거
function M.removeApi(name)
	for i, api in ipairs(M.apis) do
		if api.name == name then
			table.remove(M.apis, i)
			break
		end
	end
end

-- API 설정 가져오기
function M.getApi(name)
	for _, api in ipairs(M.apis) do
		if api.name == name then
			return api
		end
	end
	return nil
end

return M
