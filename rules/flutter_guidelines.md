# 📱 flutter_guidelines.md

## 🧭 앱 개발 기본 방향
이 앱은 **Flutter 기반의 MVVM 아키텍처**를 따르며, **Firebase**와 **Flask API**를 함께 연동해 기능을 분리합니다. MVVM은 유지보수와 기능 확장에 적합하며, AI 모델과 같은 복잡한 연산은 Flask 서버에서 처리합니다.

---

## 🔷 아키텍처 전략
### ✅ MVVM 기본 구조 유지
- **Model**: Firestore 및 Realtime DB에서 가져오는 데이터 정의
- **ViewModel**: 비즈니스 로직 처리, API 호출, 상태 관리
- **View**: UI만 담당하며, ViewModel로부터 상태를 수신

### ✅ Flask 연동 방식
- AI 분석, 얼굴 인식, 자동 심판 등의 기능은 **Flask API로 요청** → 결과 수신 후 ViewModel에서 처리
- Flutter에서는 Flask API를 `http` 패키지로 호출하며, 응답은 JSON으로 처리

---

## 📁 폴더 구조 예시
```
lib/
├── models/          # 데이터 구조 정의 (출석, 경기, AI분석 등)
├── viewmodels/      # 각 화면의 상태 관리 및 로직 처리
├── views/           # UI (페이지, 위젯 등)
├── services/        # Firebase & Flask API 연동
├── utils/           # 공통 함수, 상수, 유틸리티
└── main.dart        # 앱 시작점
```

---

## 🔗 Firebase 연동 규칙
- Firestore는 `cloud_firestore` 패키지 사용
- Realtime DB는 `firebase_database` 패키지 사용
- 인증은 `firebase_auth` 기준
- 사진 업로드나 영상은 추후 `firebase_storage` 고려

```dart
// 예시: 출석 데이터 가져오기 (Firestore)
final snapshot = await FirebaseFirestore.instance
  .collection('attendance')
  .doc(studentId)
  .get();
final data = snapshot.data();
```

---

## 🔗 Flask API 연동 예시
```dart
// 예시: 얼굴 인식 요청
final response = await http.post(
  Uri.parse('http://<SERVER_IP>:5000/api/recognize-face'),
  body: jsonEncode({ 'image_url': photoUrl }),
  headers: { 'Content-Type': 'application/json' },
);

if (response.statusCode == 200) {
  final result = jsonDecode(response.body);
  // ViewModel에서 상태 반영
}
```

---

## 📌 상태관리 규칙
- 기본은 **`ChangeNotifier` + `Provider`** 구조 사용
- 규모가 커질 경우 **Riverpod**로 점진적 전환 고려
- 각 ViewModel은 다음을 반드시 포함:
  - 상태 변수
  - 데이터 초기화 메서드 (`init()`)
  - Firebase 및 Flask 호출 함수
  - 오류 처리 및 로딩 상태 표시

---

## 🧠 테스트 전략
- ViewModel 단위 테스트 작성 가능 구조 유지
- 모든 외부 API 호출은 `services/`로 분리하여 모킹 가능하게 구성
- UI 테스트는 Flutter `WidgetTester` 활용

---

## ✅ 요약
- 앱은 MVVM으로 구성하되, 복잡한 AI/출석/경기 분석은 Flask 서버에서 담당
- ViewModel은 데이터를 중앙에서 관리하며 View는 최대한 단순하게 구성
- 데이터 변경에 강한 구조를 위해 **모든 응답에 기본값 처리와 예외 처리 필수**

📎 이 가이드는 개발팀 전체가 동일한 구조와 스타일을 따르기 위한 기준입니다.

