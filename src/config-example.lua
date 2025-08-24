-- 날씨 모니터 앱 설정 파일 예제
-- config.lua 파일을 만들 때 참고용으로 사용하세요

local config = {}

-- OpenWeatherMap API 설정
config.api = {
	-- OpenWeatherMap API 키 (https://openweathermap.org/api 에서 발급)
	-- 무료 계정으로 하루 1000회 호출 가능
	openweather_key = "여기에_실제_API_키_입력",
	-- API 요청 설정
	timeout_sec = 15, -- 요청 타임아웃 (초)
	base_url = "https://api.openweathermap.org/data/2.5/weather",
}

-- 날씨 모니터링 설정
config.weather = {
	-- 모니터링할 도시 (도시명, 국가코드)
	city = "Sydney", -- 다른 도시로 변경 가능 (예: "Seoul", "Tokyo")
	country = "AU", -- 국가 코드 (KR, JP 등)
	-- 온도 단위 (metric=섭씨, imperial=화씨, kelvin=켈빈)
	units = "metric",
	-- 업데이트 주기 (초)
	-- 너무 짧게 설정하면 API 할당량을 빨리 소모할 수 있습니다
	update_interval_sec = 600, -- 600초 (10분, 권장: 30-600초)
	-- 시작 알림 표시 여부
	show_notifications = true,
}

-- 메뉴바 표시 설정
config.menubar = {
	-- 메뉴바 초기 아이콘
	default_icon = "🌤️",
	-- 에러 시 아이콘
	error_icon = "❌",
	-- 툴팁 표시 여부
	show_tooltip = true,
	-- 메뉴바 제목 형식
	-- "temp": 온도만 표시 (예: "22°C")
	-- "icon": 아이콘만 표시 (예: "🌤️")
	title_format = "temp",
}

-- 디버그 설정
config.debug = {
	-- 콘솔에 디버그 메시지 출력 여부
	-- 문제 해결 시에만 true로 설정하세요
	enabled = false,
	-- API 응답 로깅 여부
	-- API 응답 내용을 콘솔에 출력 (디버깅용)
	log_api_responses = false,
}

-- 다른 도시 설정 예제:
-- 서울: city = "Seoul", country = "KR"
-- 도쿄: city = "Tokyo", country = "JP"
-- 뉴욕: city = "New York", country = "US"
-- 런던: city = "London", country = "GB"

return config

