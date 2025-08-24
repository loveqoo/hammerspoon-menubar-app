-- 날씨 데이터를 표시하는 메뉴바 모듈
---@diagnostic disable: undefined-global
local hs = hs  -- Hammerspoon 전역 변수

-- 설정 로드
local config = require("config")

local M = {}

-- 메뉴바 아이템 생성
function M.create()
    local menubar = hs.menubar.new()
    menubar:setTitle("...")
    menubar:setTooltip("날씨 모니터")
    
    -- 초기 메뉴 설정
    menubar:setMenu({
        { title = "로딩 중...", disabled = true }
    })
    
    return menubar
end

-- 날씨 데이터로 메뉴바 표시 업데이트
function M.updateDisplay(menubar, data)
    if not menubar then return end
    
    local menuItems = {}
    
    -- 날씨 데이터 처리
    local weather = data.weather
    if weather and not weather.error then
        -- 온도로 메뉴바 제목 업데이트
        menubar:setTitle(weather.temperature)
        local cityName = weather.city or config.weather.city
        menubar:setTooltip(cityName .. ": " .. weather.description .. " (" .. weather.timestamp .. ")")
        
        -- 상세 날씨 메뉴 구성
        table.insert(menuItems, {
            title = weather.city .. ", " .. weather.country,
            disabled = true
        })
        table.insert(menuItems, { title = "-" })
        table.insert(menuItems, {
            title = "온도: " .. weather.temperature,
            disabled = true
        })
        table.insert(menuItems, {
            title = "체감: " .. weather.feels_like,
            disabled = true
        })
        table.insert(menuItems, {
            title = "상세: " .. weather.description,
            disabled = true
        })
        table.insert(menuItems, {
            title = "바람: " .. weather.wind_speed,
            disabled = true
        })
        table.insert(menuItems, {
            title = "습도: " .. weather.humidity,
            disabled = true
        })
        table.insert(menuItems, {
            title = "기압: " .. weather.pressure,
            disabled = true
        })
    else
        -- 에러 또는 데이터 없음
        menubar:setTitle("❌")
        menubar:setTooltip("날씨 데이터 사용 불가")
        
        local errorMsg = "날씨 데이터 없음"
        if weather and weather.error then
            errorMsg = weather.error
        elseif data.weather == nil then
            errorMsg = "API 응답 없음"
        end
        
        table.insert(menuItems, {
            title = "❌ " .. errorMsg,
            disabled = true
        })
    end
    
    if #menuItems == 0 then
        table.insert(menuItems, { title = "API 미설정", disabled = true })
    end
    
    -- 구분선과 컨트롤 추가
    table.insert(menuItems, { title = "-" })
    table.insert(menuItems, { 
        title = "Details", 
        fn = function()
            local weather = data and data.weather
            M.showWeatherDetails(weather)
        end
    })
    
    -- 마지막 업데이트 시간 표시
    table.insert(menuItems, { title = "-" })
    local lastUpdateTime = os.date("마지막 업데이트: %Y-%m-%d %H:%M:%S", os.time())
    table.insert(menuItems, {
        title = lastUpdateTime .. " (" .. config.weather.update_interval_sec .. "초 간격)",
        disabled = true
    })
    
    menubar:setMenu(menuItems)
end

-- 메뉴바에 에러 표시
function M.showError(menubar, error)
    if not menubar then return end
    
    menubar:setTitle("❌ API")
    menubar:setMenu({
        { title = "오류: " .. tostring(error), disabled = true },
        { title = "-" },
        { title = "Retry", fn = function()
            hs.alert.show("재시도 중...")
        end },
        { title = "Settings", fn = function()
            M.showSettings()
        end }
    })
end

-- 상세 날씨 정보 표시
function M.showWeatherDetails(data)
    local cityName = (data and data.city) or config.weather.city
    local details = cityName .. " 날씨 상세 정보\n\n"
    
    if data and not data.error then
        details = details .. "Temperature: " .. data.temperature .. "\n"
        details = details .. "Feels like: " .. data.feels_like .. "\n"
        details = details .. "Condition: " .. data.description .. "\n"
        details = details .. "Humidity: " .. data.humidity .. "\n"
        details = details .. "Wind Speed: " .. data.wind_speed .. "\n"
        details = details .. "Pressure: " .. data.pressure .. "\n"
        details = details .. "Updated: " .. data.timestamp .. "\n"
    else
        details = details .. "오류: " .. (data and data.error or "데이터 사용 불가")
    end
    
    hs.dialog.blockAlert(
        "날씨 상세 정보",
        details,
        "확인"
    )
end

return M