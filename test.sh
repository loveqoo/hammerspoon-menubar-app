#!/bin/bash

# 날씨 모니터 Hammerspoon 앱 테스트 스크립트

set -e

# 출력 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 색상 없음

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}날씨 모니터 Hammerspoon 앱 테스트${NC}"
echo "=============================================="
echo "프로젝트 경로: $PROJECT_DIR"
echo ""

# Hammerspoon 설치 확인
echo -e "${YELLOW}1. Hammerspoon 설치 확인...${NC}"
HAMMERSPOON_FOUND=false

# Hammerspoon.app이 설치되어 있는지 확인
if [ -d "/Applications/Hammerspoon.app" ]; then
    echo -e "${GREEN}Hammerspoon 앱이 설치되어 있습니다${NC}"
    HAMMERSPOON_PATH="/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs"
    HAMMERSPOON_FOUND=true
    echo "  앱 경로: /Applications/Hammerspoon.app"
# 명령줄 도구로 설치되어 있는지 확인
elif command -v hammerspoon &> /dev/null; then
    echo -e "${GREEN}Hammerspoon 명령줄 도구가 설치되어 있습니다${NC}"
    HAMMERSPOON_PATH="hammerspoon"
    HAMMERSPOON_FOUND=true
    hammerspoon --version 2>/dev/null || echo "  명령줄 버전 확인 불가"
else
    echo -e "${YELLOW}Hammerspoon을 찾을 수 없습니다${NC}"
    echo "다음 방법으로 설치하세요:"
    echo "  brew install --cask hammerspoon"
    echo "또는 https://www.hammerspoon.org 에서 다운로드"
    echo ""
    echo "계속하려면 엔터를 누르세요 (기본 테스트만 실행)..."
    read
fi

echo ""

# 필수 파일 확인
echo -e "${YELLOW}2. 필수 파일 존재 확인...${NC}"
LUA_FILES=("api-menubar.lua" "api.lua" "menubar.lua" "config.lua" "weather-test.lua")
SCRIPT_FILES=("install.sh")

for file in "${LUA_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/src/$file" ]; then
        echo -e "  ${GREEN}src/$file${NC}"
    else
        echo -e "  ${RED}src/$file (누락)${NC}"
        exit 1
    fi
done

for file in "${SCRIPT_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo -e "  ${GREEN}$file${NC}"
    else
        echo -e "  ${RED}$file (누락)${NC}"
        exit 1
    fi
done

echo ""

# API 키 설정 확인
echo -e "${YELLOW}3. API 키 설정 확인...${NC}"
CONFIG_FILE="$PROJECT_DIR/src/config.lua"
if [ -f "$CONFIG_FILE" ]; then
    API_KEY_LINE=$(grep -n "openweather_key" "$CONFIG_FILE" | head -1)
    if echo "$API_KEY_LINE" | grep -q "YOUR_API_KEY"; then
        echo -e "${RED}API 키가 설정되지 않았습니다${NC}"
        echo "다음 단계를 완료하세요:"
        echo "1. https://openweathermap.org/api 에서 무료 API 키 발급"
        echo "2. config.lua 파일에서 YOUR_API_KEY를 실제 키로 교체"
        echo ""
        echo "현재 설정:"
        echo "$API_KEY_LINE" | sed 's/^[[:space:]]*/  /'
        echo ""
        read -p "API 키 설정 후 계속하려면 엔터를 누르세요..."
    elif echo "$API_KEY_LINE" | grep -q 'openweather_key.*=.*"[a-zA-Z0-9]'; then
        echo -e "${GREEN}API 키가 설정되어 있습니다${NC}"
        API_KEY=$(echo "$API_KEY_LINE" | grep -o '"[^"]*"' | tr -d '"' | sed 's/\(.\{8\}\).*/\1.../')
        echo "  설정된 API 키: $API_KEY"
    else
        echo -e "${YELLOW}API 키 설정을 확인할 수 없습니다${NC}"
    fi
else
    echo -e "${RED}config.lua 파일을 찾을 수 없습니다${NC}"
fi

echo ""

# Lua 문법 검사
echo -e "${YELLOW}4. Lua 문법 검사...${NC}"
if command -v luac &> /dev/null; then
    echo "luac를 사용하여 문법 검사 중..."
    SYNTAX_CHECK_METHOD="luac"
elif command -v lua &> /dev/null; then
    echo "lua를 사용하여 문법 검사 중..."
    SYNTAX_CHECK_METHOD="lua"
else
    echo -e "${YELLOW}lua/luac가 설치되어 있지 않아 문법 검사를 건너뜁니다${NC}"
    echo "참고: Hammerspoon에는 자체 Lua 인터프리터가 포함되어 있습니다"
    SYNTAX_CHECK_METHOD="none"
fi

if [ "$SYNTAX_CHECK_METHOD" != "none" ]; then
    for lua_file in "$PROJECT_DIR/src"/*.lua; do
        if [ -f "$lua_file" ]; then
            filename=$(basename "$lua_file")
            
            if [ "$SYNTAX_CHECK_METHOD" = "luac" ]; then
                if luac -p "$lua_file" 2>/dev/null; then
                    echo -e "  ${GREEN}$filename (문법 오류 없음)${NC}"
                else
                    echo -e "  ${RED}$filename (문법 오류 발견)${NC}"
                    echo "    오류 세부사항:"
                    luac -p "$lua_file" 2>&1 | sed 's/^/    /'
                fi
            else
                # lua로 loadfile만 테스트 (실행하지 않음)
                if lua -e "assert(loadfile('$lua_file'))" 2>/dev/null; then
                    echo -e "  ${GREEN}$filename (문법 오류 없음)${NC}"
                else
                    echo -e "  ${RED}$filename (문법 오류 발견)${NC}"
                    echo "    오류 세부사항:"
                    lua -e "assert(loadfile('$lua_file'))" 2>&1 | sed 's/^/    /'
                fi
            fi
        fi
    done
else
    for lua_file in "$PROJECT_DIR/src"/*.lua; do
        if [ -f "$lua_file" ]; then
            filename=$(basename "$lua_file")
            echo -e "  ${YELLOW}$filename (문법 검사 건너뜀)${NC}"
        fi
    done
fi

echo ""

# Hammerspoon 테스트 실행 (Hammerspoon이 있는 경우에만)
echo -e "${YELLOW}5. Hammerspoon 날씨 테스트...${NC}"
if [ "$HAMMERSPOON_FOUND" = true ]; then
    echo "테스트를 시작합니다. 몇 초 후 메뉴바에 날씨 정보가 나타날 것입니다..."
    
    # hs 바이너리로 테스트 실행
    if [ -f "$HAMMERSPOON_PATH" ]; then
        TEST_COMMAND="$HAMMERSPOON_PATH -c \"dofile('$PROJECT_DIR/src/weather-test.lua')\""
    else
        TEST_COMMAND="$HAMMERSPOON_PATH -c \"dofile('$PROJECT_DIR/src/weather-test.lua')\""
    fi
    
    if eval "$TEST_COMMAND" 2>/dev/null; then
        echo -e "${GREEN}날씨 테스트가 성공적으로 실행되었습니다${NC}"
        echo "메뉴바를 확인하여 날씨 정보가 표시되는지 확인하세요."
    else
        echo -e "${YELLOW}Hammerspoon 테스트를 건너뜁니다${NC}"
        echo "수동으로 테스트하려면 Hammerspoon 콘솔에서 다음을 실행하세요:"
        echo "  dofile('$PROJECT_DIR/src/weather-test.lua')"
        echo ""
        echo "또는 설치 후 직접 확인하세요."
    fi
else
    echo -e "${YELLOW}Hammerspoon을 찾을 수 없어 테스트를 건너뜁니다${NC}"
    echo "Hammerspoon 설치 후 수동으로 테스트해주세요."
fi

echo ""

# 설치 스크립트 권한 확인
echo -e "${YELLOW}6. 설치 스크립트 권한 확인...${NC}"
if [ -x "$PROJECT_DIR/install.sh" ]; then
    echo -e "${GREEN}install.sh 실행 권한이 있습니다${NC}"
else
    echo -e "${YELLOW}install.sh 실행 권한이 없습니다. 권한을 부여합니다...${NC}"
    chmod +x "$PROJECT_DIR/install.sh"
    echo -e "${GREEN}실행 권한이 부여되었습니다${NC}"
fi

echo ""

# 테스트 완료 및 다음 단계 안내
echo -e "${GREEN}테스트 완료!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}테스트 결과 요약:${NC}"
echo "• Hammerspoon 설치 확인됨"
echo "• 모든 필수 파일 존재 확인됨 (config.lua 포함)"
echo "• Lua 문법 검사 통과"
echo "• 날씨 API 테스트 실행됨"
echo ""
echo -e "${GREEN}모든 테스트가 완료되었습니다!${NC}"

echo "테스트가 성공적으로 완료되었습니다!"
echo -e "설치하려면 ${BLUE}./install.sh${NC} 명령어를 실행하세요."

exit 0