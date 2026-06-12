# MemoQuest - Smart Study Notes & Flashcard RPG

MemoQuest là ứng dụng học tập trên Android được xây dựng bằng Flutter. App tập trung vào flow ghi chú, tạo flashcard, ôn tập bằng quiz, và theo dõi tiến độ học tập bằng XP, level, streak.

## Team Members
- Member 1
- Member 2
- Member 3
- Member 4

## Features
- Login/logout mock
- Home dashboard
- Notes CRUD
- Flashcard CRUD
- Review flashcard
- Quiz mode
- Statistics
- XP, level, streak
- Notification reminder

## Tech Stack
- Flutter
- Dart
- Provider
- SQLite / sqflite
- SharedPreferences
- flutter_local_notifications

## How To Run
```bash
flutter pub get
flutter run
```

## Demo Account
- Username: demo
- Password: 123456

## Folder Structure
```text
lib/
  core/
  data/
  features/
  services/
```

## Screenshots
- Home screen
- Notes screen
- Flashcard screen
- Quiz screen

## Project Guide
- Xem tài liệu chi tiết tại [MEMOQUEST_PROJECT_GUIDE.md](/D:/memoquest/memoquest/MEMOQUEST_PROJECT_GUIDE.md)

## Notes
- App dùng SQLite nên không cần server riêng.
- Khi đổi schema database, cần tăng version và viết `onUpgrade`, hoặc clear app data trong giai đoạn dev.
