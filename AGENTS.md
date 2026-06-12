# AGENTS.md

## Mục tiêu của file này

File này giúp AI agent định hướng nhanh trong repo `memoquest` mà không cần đọc toàn bộ project.

Nguyên tắc:
- Đọc ít nhưng đúng chỗ
- Chỉ mở thêm file khi task thực sự cần
- Không quét toàn repo nếu yêu cầu chỉ liên quan đến UI, tài liệu, hoặc cấu hình nhỏ

## Đọc theo thứ tự ưu tiên

Khi bắt đầu làm việc, ưu tiên đọc theo thứ tự sau:

1. `AGENTS.md`
2. `README.md`
3. `pubspec.yaml`
4. `lib/main.dart`

Chỉ đọc thêm các file khác nếu task yêu cầu.

## Routing theo loại yêu cầu

### 1. Nếu task là hiểu tổng thể dự án

Đọc:
- `README.md`
- `MEMOQUEST_PROJECT_GUIDE.md`

Không cần đọc:
- `android/`
- `ios/`
- `test/`

### 2. Nếu task là tạo hoặc chỉnh UI Flutter

Đọc:
- `MEMOQUEST_UI_PROMPTS.md`
- `lib/main.dart`
- `pubspec.yaml`

Nếu chỉ đang viết prompt hoặc đặc tả UI:
- Không cần đọc `android/`, `ios/`, `test/`

Nếu đang code UI thật:
- Chỉ mở thêm các file widget/screen liên quan

### 3. Nếu task là chỉnh cấu hình package hoặc dependency

Đọc:
- `pubspec.yaml`
- `README.md`

Chỉ mở thêm khi cần:
- `android/app/src/main/AndroidManifest.xml`

### 4. Nếu task là sửa entry point hoặc app bootstrap

Đọc:
- `lib/main.dart`
- `pubspec.yaml`

Chỉ đọc thêm guide nếu cần hiểu business flow:
- `MEMOQUEST_PROJECT_GUIDE.md`

### 5. Nếu task là viết tài liệu, kế hoạch, chia việc, database, flow

Đọc:
- `MEMOQUEST_PROJECT_GUIDE.md`
- `README.md`

Nếu task liên quan UI prompt:
- Đọc thêm `MEMOQUEST_UI_PROMPTS.md`

### 6. Nếu task là debug Android native

Chỉ khi thật sự cần mới đọc:
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/.../MainActivity.kt`

Không cần đọc guide nghiệp vụ nếu lỗi thuần native/build.

### 7. Nếu task là test

Đọc:
- `test/widget_test.dart`
- File Dart đang được test

Không cần đọc toàn bộ guide nếu chỉ fix unit/widget test nhỏ.

## Trạng thái repo hiện tại

Hiện tại repo còn rất sớm, chưa tách architecture hoàn chỉnh.

File đáng chú ý:
- `lib/main.dart`: entry point hiện tại
- `pubspec.yaml`: dependency hiện tại
- `MEMOQUEST_PROJECT_GUIDE.md`: tài liệu nghiệp vụ và định hướng project
- `MEMOQUEST_UI_PROMPTS.md`: prompt ngắn cho UI Flutter
- `README.md`: mô tả ngắn dự án

## Khi nào KHÔNG cần đọc hết repo

Không đọc toàn repo nếu yêu cầu thuộc một trong các nhóm sau:
- Viết prompt UI
- Viết Markdown/documentation
- Chỉnh README
- Chỉnh dependency nhỏ
- Review ý tưởng tính năng
- Tạo kế hoạch chia việc

Khi đó chỉ đọc các file root liên quan.

## Khi nào CẦN mở rộng phạm vi đọc

Chỉ mở rộng đọc thêm nếu:
- Cần sửa code thật
- Cần debug build/runtime
- Cần trace luồng state/navigation
- Cần sửa bug có liên quan nhiều module
- Cần thêm package ảnh hưởng Android manifest hoặc permission

## Quy ước đọc file tối thiểu

### Cho task UI

Đủ dùng:
- `AGENTS.md`
- `MEMOQUEST_UI_PROMPTS.md`
- `lib/main.dart`

### Cho task tài liệu

Đủ dùng:
- `AGENTS.md`
- `README.md`
- `MEMOQUEST_PROJECT_GUIDE.md`

### Cho task setup Flutter

Đủ dùng:
- `AGENTS.md`
- `pubspec.yaml`
- `lib/main.dart`

## Định hướng khi repo mở rộng sau này

Khi project được tách module, nên giữ routing như sau:

- `lib/core/`: constants, theme, utils dùng chung
- `lib/data/models/`: model
- `lib/data/repositories/`: repository
- `lib/features/auth/`: auth screens và provider
- `lib/features/notes/`: notes flow
- `lib/features/flashcards/`: flashcard flow
- `lib/features/quiz/`: quiz flow
- `lib/features/stats/`: thống kê
- `lib/services/db/`: SQLite helper, migration
- `lib/services/storage/`: SharedPreferences
- `lib/services/notification/`: local notification

Khi đó AI chỉ nên đọc folder của feature liên quan thay vì đọc toàn bộ `lib/`.

## Prompt ngắn đề xuất cho AI

Có thể dùng prompt mở đầu này:

```text
Đọc AGENTS.md trước.
Chỉ mở các file tối thiểu liên quan đến task.
Không quét toàn repo nếu chưa cần.
Nếu task là UI hoặc tài liệu, ưu tiên đọc file markdown ở root trước.
```

## Ghi chú thực dụng

- `MEMOQUEST_PROJECT_GUIDE.md` là file hiểu nghiệp vụ
- `MEMOQUEST_UI_PROMPTS.md` là file hiểu cách ra UI đẹp mà gọn token
- `pubspec.yaml` là file hiểu dependency
- `lib/main.dart` là file hiểu điểm vào app

Nếu chưa chắc phải đọc gì, bắt đầu từ 4 file:
- `AGENTS.md`
- `README.md`
- `pubspec.yaml`
- `lib/main.dart`
