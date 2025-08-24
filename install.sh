#!/bin/bash

# API 메뉴바 Hammerspoon 모듈 설치 스크립트

set -e

# 출력 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 색상 없음

# 설정
HAMMERSPOON_DIR="$HOME/.hammerspoon"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_FILE="$HAMMERSPOON_DIR/init.lua"
MODULE_NAME="api-menubar"

echo -e "${GREEN}날씨 모니터 Hammerspoon 앱 설치 스크립트${NC}"
echo "================================================"

# Hammerspoon 설치 확인
HAMMERSPOON_INSTALLED=false
if command -v hammerspoon &> /dev/null; then
    echo -e "${GREEN}Hammerspoon 명령줄 도구 발견${NC}"
    HAMMERSPOON_INSTALLED=true
elif [ -d "/Applications/Hammerspoon.app" ]; then
    echo -e "${GREEN}Hammerspoon 앱 발견${NC}"
    HAMMERSPOON_INSTALLED=true
else
    echo -e "${YELLOW}경고: Hammerspoon이 설치되어 있지 않습니다${NC}"
    echo "다음 방법으로 Hammerspoon을 설치하세요:"
    echo "  brew install --cask hammerspoon"
    echo "또는 https://www.hammerspoon.org 에서 다운로드"
    echo ""
fi

# Hammerspoon 디렉토리가 없으면 생성
if [ ! -d "$HAMMERSPOON_DIR" ]; then
    echo -e "${YELLOW}Hammerspoon 디렉토리 생성 중...${NC}"
    mkdir -p "$HAMMERSPOON_DIR"
fi

# 모듈 파일 복사
echo -e "${GREEN}모듈 파일 복사 중...${NC}"
FILES=("api-menubar.lua" "api.lua" "menubar.lua" "config.lua")

for file in "${FILES[@]}"; do
    if [ -f "$PROJECT_DIR/src/$file" ]; then
        cp "$PROJECT_DIR/src/$file" "$HAMMERSPOON_DIR/"
        echo "  $file 복사 완료"
    else
        echo -e "${RED}  $file 파일 누락${NC}"
        exit 1
    fi
done

# config.lua 처리 - API 키 설정 확인
echo -e "${YELLOW}API 키 설정 확인 중...${NC}"
CONFIG_FILE="$HAMMERSPOON_DIR/config.lua"
if grep -q "YOUR_API_KEY" "$CONFIG_FILE"; then
    echo -e "${RED}API 키가 아직 설정되지 않았습니다!${NC}"
    echo "$CONFIG_FILE을 편집하여 OpenWeatherMap API 키를 설정하세요"
    echo "무료 API 키 발급: https://openweathermap.org/api"
    echo ""
else
    echo -e "${GREEN}API 키가 설정되어 있는 것 같습니다${NC}"
fi

# init.lua 처리
if [ -f "$INIT_FILE" ]; then
    echo -e "${YELLOW}기존 init.lua 업데이트 중...${NC}"
    
    # 모듈이 이미 require 되었는지 확인
    if grep -q "require.*$MODULE_NAME" "$INIT_FILE"; then
        echo "  모듈이 이미 init.lua에 추가되어 있습니다"
    else
        # require 라인 추가
        echo "" >> "$INIT_FILE"
        echo "-- 날씨 모니터 모듈" >> "$INIT_FILE"
        echo "local apiMenubar = require('$MODULE_NAME')" >> "$INIT_FILE"
        echo "apiMenubar.init()" >> "$INIT_FILE"
        echo "  init.lua에 모듈 require 추가 완룜"
    fi
else
    echo -e "${GREEN}새 init.lua 생성 중...${NC}"
    cat > "$INIT_FILE" << EOF
-- Hammerspoon Configuration

-- 날씨 모니터 모듈
local apiMenubar = require('$MODULE_NAME')
apiMenubar.init()

hs.alert.show("Hammerspoon loaded")
EOF
    echo "  모듈이 포함된 새 init.lua 생성 완료"
fi

# 실행 권한 설정
chmod +x "$0"

echo ""
if [ "$HAMMERSPOON_INSTALLED" = true ]; then
    echo -e "${GREEN}설치 완료!${NC}"
    echo "================================================"
    echo "파일 설치 위치: $HAMMERSPOON_DIR"
    echo "모듈 추가 위치: $INIT_FILE"
    echo ""
    echo -e "${YELLOW}다음 단계:${NC}"
    echo "1. Hammerspoon 설정 다시 로드:"
    echo "   - Hammerspoon 앱 열기"
    echo "   - 'Reload Config' 클릭 또는 ⌘+R 눌러서"
    echo ""
    echo "2. API 키와 모니터링 지역을 설정하세요:"
    echo "   $HAMMERSPOON_DIR/config.lua"
    echo "   API 키 발급: https://openweathermap.org/api"
    echo ""
    echo "3. 날씨 정보가 메뉴바에 나타납니다"
else
    echo -e "${YELLOW}파일 설치 완료 (하지만 Hammerspoon이 필요합니다)${NC}"
    echo "================================================"
    echo "파일 설치 위치: $HAMMERSPOON_DIR"
    echo "모듈 추가 위치: $INIT_FILE"
    echo ""
    echo -e "${RED}중요: 작동하려면 먼저 Hammerspoon을 설치하세요!${NC}"
    echo "설치 방법:"
    echo "  brew install --cask hammerspoon"
    echo "또는 https://www.hammerspoon.org 에서 다운로드"
    echo ""
    echo "Hammerspoon 설치 후:"
    echo "1. Hammerspoon 앱 열기"
    echo "2. 'Reload Config' 클릭 또는 ⌘+R"
    echo "3. API 키 설정: $HAMMERSPOON_DIR/config.lua"
fi
echo ""
echo -e "${GREEN}유용한 명령어:${NC}"
echo "  hammerspoon -c 'hs.reload()'  # 설정 다시 로드"
echo "  hammerspoon -c 'hs.console.alpha(1)'  # 콘솔 보이기"
echo ""

echo -e "${GREEN}설치 완료! Hammerspoon 앱에서 수동으로 'Reload Config'를 실행해주세요.${NC}"

exit 0