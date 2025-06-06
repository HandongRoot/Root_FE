#!/bin/bash

# 1. .env 파일에서 환경 변수 불러오기
export $(grep -v '^#' .env | xargs)

# 2. Info.plist.template를 복사해서 Info.plist 만들기
cp ios/Runner/Info.plist.template ios/Runner/Info.plist

# 3. placeholder(__KAKAO_URL_SCHEME__)를 실제 kakao{앱키}로 치환
sed -i '' "s/__KAKAO_URL_SCHEME__/kakao$KAKAO_NATIVE_KEY/" ios/Runner/Info.plist

echo "✅ Info.plist has been generated with your Kakao URL scheme!"

# -----------------------------------