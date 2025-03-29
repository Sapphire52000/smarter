**firebase_data_structure.md**

# 📦 Firebase 데이터 구조 설계

> 이 문서는 스마트 탁구장 시스템(Pingtelligent)에서 사용하는 Firebase 데이터베이스 구조를 정의합니다. 실시간 처리에는 **Realtime Database**, 기록 저장 및 쿼리에는 **Cloud Firestore**를 사용합니다.

---

## 🔥 1. Firestore 구조 (기록용)

### ✅ 1.1 출석 기록 - `attendance`
```json
attendance (collection)
├── student_id (document)
    ├── name: string
    ├── photo_url: string
    ├── total_attendance: number
    ├── dates: {
         "2025-03-20": true,
         "2025-03-21": false
       }
```
- ✅ 출석 여부는 날짜 키를 기준으로 boolean 저장
- ✅ `total_attendance`는 자동 계산용 (앱에서 참고)

---

### ✅ 1.2 시간표 - `schedules`
```json
schedules (collection)
├── coach_id (document)
    ├── name: string
    ├── schedule: [
         {
           "date": "2025-03-22",
           "time": "14:00",
           "student": "김철수"
         },
         ...
       ]
```
- ✅ 코치별 스케줄 관리
- ✅ GPT가 메시지를 분석해 이 컬렉션에 자동 반영함

---

### ✅ 1.3 경기 기록 - `matches`
```json
matches (collection)
├── match_id (document)
    ├── table_id: string
    ├── players: { player1: string, player2: string }
    ├── score: { player1: number, player2: number }
    ├── winner: string
    ├── timestamp: string (ISO8601)
```
- ✅ 경기 종료 시 자동 저장
- ✅ 경기별 분석 연동을 위해 `match_id` 기준

---

### ✅ 1.4 AI 분석 데이터 - `ai_analysis`
```json
ai_analysis (collection)
├── match_id (document)
    ├── player1: string
    ├── player2: string
    ├── ball_speeds: [
         { "time": "00:01", "speed": 5.2 },
         ...
       ]
    ├── hit_locations: [
         { "player": "김철수", "x": 120, "y": 80 },
         ...
       ]
```
- ✅ 공의 속도 및 충돌 위치 데이터 저장
- ✅ 나중에 분석용 차트나 AI 피드백에 사용

---

## ⚡ 2. Realtime Database 구조 (실시간용)

### ✅ 2.1 실시간 경기 점수판 - `live_matches`
```json
live_matches
├── table_1
    ├── player1: "김철수"
    ├── player2: "박영희"
    ├── score1: 7
    ├── score2: 9
    ├── status: "in_progress"  // or "finished"
```
- ✅ 점수판 버튼 or AI 심판 → 실시간 업데이트
- ✅ Flutter 앱 & LED 점수판과 동기화됨

---

## 🧠 3. 유연성 고려사항 (데이터 구조 변경 대응)
- 모든 필드는 optional로 처리 (`null` 허용)
- `Map<String, dynamic>` 구조로 유연하게 받도록 설계
- 구조 변경 시에도 앱이 터지지 않도록 기본값 지정 필수
- ViewModel 내 기본값 처리 및 null-safe 로직 강제 적용

---

## 📌 참고 사항
- 출석 기록은 Firestore 기준이며, 실시간 확인은 앱에서 캐싱 처리 가능
- 실시간 점수판은 빠르게 Firebase Realtime DB에 반영되어야 함
- AI 분석 결과는 비동기 저장되므로 앱 UI에 분석 준비 완료 여부 표시 필요

---

✅ 이 데이터 구조를 기준으로 Flutter MVVM 앱과 Flask API, 라즈베리파이 연동 구조가 통일됩니다. 이후 구조가 변경되면 반드시 이 문서를 업데이트해야 합니다.

