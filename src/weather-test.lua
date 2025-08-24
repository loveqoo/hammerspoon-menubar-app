-- 날씨 모니터 테스트 스크립트
-- 날씨 API 통합 기능을 테스트하려면 이 스크립트를 실행하세요
---@diagnostic disable: undefined-global
local hs = hs  -- Hammerspoon 전역 변수

-- Add current directory to package path
local scriptPath = debug.getinfo(1, "S").source:match("@(.*/)")
package.path = scriptPath .. "?.lua;" .. package.path

print("Testing Weather Monitor Integration...")

-- Load modules
local api = require("api")
local menubar = require("menubar")

-- Add OpenWeatherMap API key prompt
print("\n=== API Key Setup ===")
print("You need an OpenWeatherMap API key to test this.")
print("1. Get a free API key from: https://openweathermap.org/api")
print("2. Replace 'YOUR_API_KEY' in api.lua with your actual key")
print("3. Current API config:")

local weatherApi = api.getApi("weather")
if weatherApi then
    print("  URL: " .. weatherApi.url)
    if string.find(weatherApi.url, "YOUR_API_KEY") then
        print("  ⚠️  API key not configured yet!")
    else
        print("  ✅ API key appears to be configured")
    end
end

-- Test weather API
print("\n=== Testing Weather API ===")
api.fetchAllApis(function(results, errors)
    local weather = results.weather
    
    if errors and errors.weather then
        print("❌ Weather API Error: " .. errors.weather)
        if string.find(errors.weather, "401") then
            print("   This is likely due to invalid API key")
        end
    elseif weather then
        print("✅ Weather data received:")
        print("   City: " .. (weather.city or "Unknown"))
        print("   Temperature: " .. (weather.temperature or "Unknown"))
        print("   Description: " .. (weather.description or "Unknown"))
        print("   Humidity: " .. (weather.humidity or "Unknown"))
        print("   Wind: " .. (weather.wind_speed or "Unknown"))
        
        -- Test menubar display
        print("\n=== Testing Menubar Display ===")
        local testMenubar = menubar.create()
        menubar.updateDisplay(testMenubar, results)
        print("✅ Menubar updated - check your menu bar for weather!")
        
        -- Cleanup after 10 seconds
        hs.timer.doAfter(10, function()
            if testMenubar then
                testMenubar:delete()
                print("Test menubar cleaned up")
            end
        end)
    else
        print("❌ No weather data received")
    end
end)

print("\n=== API Configuration Help ===")
print("To configure your API key:")
print("1. Edit api.lua")
print("2. Replace 'YOUR_API_KEY' with your OpenWeatherMap API key")
print("3. The URL should look like:")
print("   https://api.openweathermap.org/data/2.5/weather?q=Sydney,AU&appid=abc123&units=metric")

print("\n=== Next Steps ===")
print("1. Configure your API key in api.lua")
print("2. Run this test again to verify it works")
print("3. Install with: ./install.sh")
print("4. Reload Hammerspoon to start monitoring Sydney weather!")