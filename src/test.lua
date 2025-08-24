-- Test script for API Menubar module
-- Run this with: hammerspoon -c "dofile('/path/to/test.lua')"
---@diagnostic disable: undefined-global
local hs = hs -- Hammerspoon 전역 변수

-- Add current directory to package path
local scriptPath = debug.getinfo(1, "S").source:match("@(.*/)")
package.path = scriptPath .. "?.lua;" .. package.path

print("Starting API Menubar test...")

-- Test API module
print("\n=== Testing API Module ===")
local api = require("api")

-- Add test APIs
api.addApi("httpbin", "https://httpbin.org/json", {
	method = "GET",
	timeout_sec = 5,
	parser = function(data)
		return {
			status = "success",
			origin = data.origin or "unknown",
		}
	end,
})

api.addApi("jsonplaceholder", "https://jsonplaceholder.typicode.com/posts/1", {
	method = "GET",
	timeout_sec = 5,
	parser = function(data)
		return {
			title = data.title,
			userId = data.userId,
		}
	end,
})

-- Test API fetching
print("Testing API fetch...")
api.fetchAllApis(function(results, errors)
	print("API Results:")
	for name, data in pairs(results) do
		print("  " .. name .. ":", hs.inspect(data))
	end

	if errors then
		print("API Errors:")
		for name, error in pairs(errors) do
			print("  " .. name .. ":", error)
		end
	end
end)

-- Test menubar module
print("\n=== Testing Menubar Module ===")
local menubar = require("menubar")

-- Create test menubar
local testMenubar = menubar.create()
print("Menubar created")

-- Test with sample data
local sampleData = {
	api1 = { status = "ok", message = "Service running" },
	api2 = { error = "Connection timeout" },
	api3 = "Simple string response",
}

menubar.updateDisplay(testMenubar, sampleData)
print("Menubar updated with sample data")

-- Test main module
print("\n=== Testing Main Module ===")
local apiMenubar = require("api-menubar")

-- Initialize with test config
---@diagnostic disable-next-line: unused-local
local app = apiMenubar.init({
	updateInterval = 5,
	showNotifications = true,
})

print("Main module initialized")

-- Wait a bit then show results
hs.timer.doAfter(3, function()
	print("Test completed! Check your menubar for the API status.")
	print("You can now install with: ./install.sh")
	-- Cleanup test menubar
	if testMenubar then
		testMenubar:delete()
	end
end)

print("\n=== Test Summary ===")
print("✅ API module loaded")
print("✅ Menubar module loaded")
print("✅ Main module loaded")
print("✅ Test APIs configured")
print("✅ Menubar item created")
print("\nThe API menubar should now be visible in your menu bar.")
print("Check the dropdown menu to see API status updates.")

