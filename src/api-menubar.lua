-- Hammerspoon용 API 메뉴바 모듈
-- init.lua에서 require로 불러올 메인 모듈 파일
---@diagnostic disable: undefined-global
local hs = hs -- Hammerspoon 전역 변수

local M = {}

-- 현재 모듈 디렉토리 경로 가져오기
local modulePath = debug.getinfo(1, "S").source:match("@(.*/)")
if modulePath then
	package.path = modulePath .. "?.lua;" .. package.path
end

-- 하위 모듈 로드
local config = require("config")
local api = require("api")
local menubar = require("menubar")

-- 모듈 상태
M.menubarItem = nil
M.timer = nil

-- 모듈 초기화
function M.init(userConfig)
	-- config 파일의 설정을 기본값으로 사용
	M.config = {
		updateInterval = config.weather.update_interval_sec,
		showNotifications = config.weather.show_notifications,
	}
	-- 사용자 설정으로 덮어쓰기
	if userConfig then
		for k, v in pairs(userConfig) do
			M.config[k] = v
		end
	end
	-- API 모듈 초기화
	api.init()
	M.menubarItem = menubar.create()
	M:startPolling()
	if M.config.showNotifications then
		hs.alert.show("👻 초기화 완료")
	end
	return M
end

-- API 폴링 시작
function M:startPolling()
	if self.timer then
		self.timer:stop()
	end
	self.timer = hs.timer.doEvery(self.config.updateInterval, function()
		api.fetchAllApis(function(data, errors)
			if errors then
				menubar.showError(self.menubarItem, errors)
			else
				menubar.updateDisplay(self.menubarItem, data)
			end
		end)
	end)
	-- 초기 데이터 가져오기
	api.fetchAllApis(function(data, errors)
		if errors then
			menubar.showError(self.menubarItem, errors)
		else
			menubar.updateDisplay(self.menubarItem, data)
		end
	end)
end

-- 모듈 중지
function M:stop()
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
	if self.menubarItem then
		self.menubarItem:delete()
		self.menubarItem = nil
	end
end

-- 새 설정으로 재시작
function M:restart(userConfig)
	self:stop()
	M.init(userConfig)
end

return M

