# 날씨 모니터 Hammerspoon 앱

Hammerspoon을 사용하여 macOS 메뉴바에 원하는 지역의 날씨 정보를 표시합니다.

## 기능

- 🌡️ 메뉴바에 현재 온도 표시
- 🌤️ 드롭다운 메뉴에서 상세 날씨 정보 확인
- 🔄 30초마다 자동 업데이트
- 📊 습도, 바람, 기압 등 상세 날씨 정보
- ⚙️ 업데이트 주기 설정 가능

## 설정 방법

### 1. OpenWeatherMap API 키 발급
1. [OpenWeatherMap API](https://openweathermap.org/api) 방문
2. 무료 계정 생성
3. API 키 발급

### 2. API 키 및 지역 설정
`config.lua` 파일을 편집하여 API 키와 모니터링할 지역을 설정하세요:
```lua
config.api.openweather_key = "실제_API_키"
config.weather.city = "원하는_도시명"  -- 예: "Seoul", "Tokyo", "London"
config.weather.country = "국가코드"    -- 예: "KR", "JP", "GB"
```

### 3. 통합 테스트
```bash
hammerspoon -c "dofile('$(pwd)/weather-test.lua')"
```

### 4. Hammerspoon에 설치
```bash
./install.sh
```

### 5. Hammerspoon 다시 로드
Hammerspoon 앱을 열고 "Reload Config"를 클릭하거나 ⌘+R을 누르세요.

## 메뉴바 표시

- **온도**: 현재 온도 표시 (예: "22°C")
- **오류**: 날씨 데이터를 사용할 수 없을 때 "❌" 표시
- **툴팁**: 간단한 날씨 설명 표시

## 드롭다운 메뉴

- 🏙️ 설정된 위치 (예: 서울, 대한민국)
- 🌡️ 현재 온도
- 🤗 체감 온도
- ☁️ 날씨 상태
- 💨 풍속
- 💧 습도
- 📊 기압
- ⏰ 마지막 업데이트 시간
- 🔄 수동 새로고침
- 📊 상세 날씨 보기
- ⚙️ 설정

## 설정

### 지역 변경
`config.lua`에서 모니터링할 지역을 변경할 수 있습니다:
```lua
config.weather = {
    city = "Seoul",      -- 도시명
    country = "KR",     -- 국가코드
    units = "metric"    -- 온도 단위 (metric=섭씨)
}
```

### 업데이트 주기 설정
`~/.hammerspoon/init.lua`에서 초기화 설정을 편집할 수 있습니다:
```lua
local apiMenubar = require('api-menubar')
apiMenubar.init({
    updateInterval = 60,        -- 60초마다 업데이트 (내부에서 config.weather.update_interval_sec 사용)
    showNotifications = false   -- 시작 알림 비활성화
})
```

## 파일 구성

- `api-menubar.lua` - 메인 모듈
- `api.lua` - 날씨 API 연동
- `menubar.lua` - 메뉴바 표시 로직
- `weather-test.lua` - 날씨 API 테스트 스크립트
- `install.sh` - 설치 스크립트

## 문제 해결

### 메뉴바에 "❌"가 표시될 때
- API 키가 올바른지 확인
- 인터넷 연결 상태 확인
- Hammerspoon 콘솔에서 오류 세부 정보 확인

### 메뉴바 항목이 표시되지 않을 때
- Hammerspoon이 실행 중인지 확인
- `~/.hammerspoon/init.lua`에 require 문이 포함되어 있는지 확인
- Hammerspoon 설정을 다시 로드

### API 오류
- OpenWeatherMap API 키가 활성화되어 있는지 확인
- API 할당량 제한 확인 (무료 등급: 일 1000회)
- API URL 형식이 올바른지 확인