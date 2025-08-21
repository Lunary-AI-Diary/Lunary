# Lunary 🌙
> From Chats to Chapters \
> 나만의 AI 일기장 - 루나리(Lunary)

## 🌟 프로젝트 소개
Lunary는 사용자의 감정을 이해하고 기록하는 **AI 기반 감성 일기장 앱**입니다.  
사용자와 AI간 채팅을 바탕으로 **자동으로 일기와 감정 분석 및 리뷰**를 생성합니다. 일상을 돌아보고 감정을 성찰하며, 나만의 이야기로 하루를 마무리할 수 있습니다.

### ✨ 주요 기능

- 💬 **AI 채팅**: 사용자와 AI간 채팅.  
- 📖 **AI 일기**: 채팅 내용을 바탕으로 일기 자동 작성  
- 📊 **AI 리뷰**: 감정 상태 그래프, AI의 오늘의 조언 제공  
- 📅 **달력 UI**: 대화 및 일기/리뷰 기록 확인  

### 🛠️ 프로젝트 구조

- **Frontend**: Flutter  
- **Backend**: Firebase (Authentication, Firestore)  
- **AI 기능**: OpenAI API
- **디자인**: Flutter Material Widget
- **주요 디렉토리**:
```
lib/
├─models # 데이터 모델 클래스
├─screens # 앱 주요 화면
│  ├─auth
│  ├─chat
│  ├─diary
│  └─home
├─services # Firebase 및 OpenAI API
├─utils # 유틸
└─widgets # 공통 위젯 혹은 부수적인 위젯
    ├─auth
    ├─calendar
    ├─chat
    ├─diary
    └─profile
asset/ # 이미지 등 기타 파일
```
## 🚀 설치 및 실행
### 1. 안드로이드 전용 APK 설치
최초 버전 2025-08-21

### 2. 직접 빌드
1. 프로젝트 클론
 ```bash
 git clone https://github.com/username/lunary.git
 cd lunary
 ```
2. 패키지 설치
```bash
flutter pub get
```

3. Firebase 설정 
- 프로젝트에 개인 Firebase 설정 초기화
```
# 아래 세 파일을 따로 준비하세요
Lunary/
└─android/
    └─app
        └─ google-services.json
└─lib/
    └─firebase_options.dart
└─firebase.json
```

4. 앱 실행
```bash
flutter run
```

## 🤝 Contribution

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Trademark
"Lunary" name and logo are claimed as brand identifiers of this project.  
You may not use the "Lunary" name or logo in a way that suggests official affiliation without prior written permission.
See the [TRADEMARK.md](TRADEMARK.md) file for more details.
