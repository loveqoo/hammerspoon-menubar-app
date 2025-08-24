-- 날씨 데이터를 표시하는 메뉴바 모듈
---@diagnostic disable: undefined-global
local hs = hs -- Hammerspoon 전역 변수

-- 설정 로드
local config = require("config")

local M = {}

-- 메뉴바 아이템 생성
function M.create()
	local menubar = hs.menubar.new()
	menubar:setTitle("👻")
	menubar:setTooltip("Hammerspoon 유틸리티")
	-- 초기 메뉴 설정
	menubar:setMenu({
		{ title = "로딩 중...", disabled = true },
	})
	return menubar
end

-- 메뉴바 표시 업데이트
function M.updateDisplay(menubar, data)
	if not menubar then
		return
	end
	
	local menuItems = {}
	
	-- 날씨 서브메뉴 생성
	local weatherSubMenu = M.createWeatherSubMenu(data.weather)
	table.insert(menuItems, {
		title = "날씨",
		menu = weatherSubMenu
	})
	
	menubar:setMenu(menuItems)
end

-- 날씨 서브메뉴 생성
function M.createWeatherSubMenu(weather)
	local subMenuItems = {}
	
	if weather and not weather.error then
		-- 상세 날씨 메뉴 구성
		table.insert(subMenuItems, {
			title = weather.city .. ", " .. weather.country,
			disabled = true,
		})
		table.insert(subMenuItems, { title = "-" })
		table.insert(subMenuItems, {
			title = "온도: " .. weather.temperature,
			disabled = true,
		})
		table.insert(subMenuItems, {
			title = "체감: " .. weather.feels_like,
			disabled = true,
		})
		table.insert(subMenuItems, {
			title = "상태: " .. weather.description,
			disabled = true,
		})
		table.insert(subMenuItems, {
			title = "바람: " .. weather.wind_speed,
			disabled = true,
		})
		table.insert(subMenuItems, {
			title = "습도: " .. weather.humidity,
			disabled = true,
		})
		table.insert(subMenuItems, {
			title = "기압: " .. weather.pressure,
			disabled = true,
		})
		table.insert(subMenuItems, { title = "-" })
		table.insert(subMenuItems, {
			title = "상세 정보",
			fn = function()
				M.showWeatherDetails(weather)
			end,
		})
	else
		-- 에러 또는 데이터 없음
		local errorMsg = "날씨 데이터 없음"
		if weather and weather.error then
			errorMsg = weather.error
		elseif weather == nil then
			errorMsg = "API 응답 없음"
		end
		table.insert(subMenuItems, {
			title = "오류: " .. errorMsg,
			disabled = true,
		})
		table.insert(subMenuItems, { title = "-" })
		table.insert(subMenuItems, {
			title = "재시도",
			fn = function()
				hs.alert.show("재시도 중...")
			end,
		})
	end
	
	return subMenuItems
end

-- 메뉴바에 에러 표시
function M.showError(menubar, error)
	if not menubar then
		return
	end
	menubar:setTitle("ERR")
	menubar:setTooltip("오류 발생: " .. tostring(error))
	menubar:setMenu({
		{ title = "오류: " .. tostring(error), disabled = true },
		{ title = "-" },
		{
			title = "재시도",
			fn = function()
				hs.alert.show("재시도 중...")
			end,
		}
	})
end

-- 상세 날씨 정보 표시
function M.showWeatherDetails(data)
	local cityName = (data and data.city) or config.weather.city
	local details = cityName .. " 날씨 상세 정보\n\n"
	if data and not data.error then
		details = details .. "온도: " .. data.temperature .. "\n"
		details = details .. "체감온도: " .. data.feels_like .. "\n"
		details = details .. "상태: " .. data.description .. "\n"
		details = details .. "습도: " .. data.humidity .. "\n"
		details = details .. "바람세기: " .. data.wind_speed .. "\n"
		details = details .. "기압: " .. data.pressure .. "\n"
		details = details .. "수정: " .. data.timestamp .. "\n"
		details = details .. "주기: " .. (config.weather.update_interval_sec or "N/A") .. "초\n"
	else
		details = details .. "오류: " .. (data and data.error or "데이터 사용 불가")
	end
	hs.dialog.blockAlert("날씨 상세 정보", details, "확인")
end

return M

