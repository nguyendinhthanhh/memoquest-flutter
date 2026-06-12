# MEMOQUEST_UI_PROMPTS

Tài liệu này chứa các prompt ngắn gọn để bạn dùng với AI khi muốn sinh UI Flutter cho MemoQuest mà không tốn quá nhiều token.

## 1. Rule chung để giữ prompt gọn

- Gọi đúng tên screen
- Nói rõ input, output, state
- Chỉ nhắc package khi thật sự cần
- Yêu cầu tạo widget tại mức vừa đủ, không xin full app
- Nếu cần sửa UI, chỉ gửi file liên quan thay vì paste cả project

## 2. Base prompt tái sử dụng

```text
Bạn là senior Flutter developer.
Hãy tạo UI cho [SCREEN_NAME] của app MemoQuest.
Yêu cầu:
- Material 3, clean, modern, smooth
- Android-first
- UI đẹp nhưng code gọn, dễ maintain
- Tách widget hợp lý, không làm file quá dài
- Có loading, empty, error state nếu cần
- Dùng màu học tập: xanh navy, xanh mint, vàng nhạt
- Khoảng cách đều, card bo góc, icon rõ ràng
- Không viết full app, chỉ tạo screen và widget liên quan
Output: 1 file Dart hoàn chỉnh cho screen đó
```

## 3. Prompt theo màn hình

### SplashScreen

```text
Tạo SplashScreen cho MemoQuest bằng Flutter.
Yêu cầu: logo ở giữa, slogan ngắn, background gradient nhẹ, animation fade in 600ms.
Sau khi load thì có chỗ route tiếp, nhưng không cần viết logic auth thật.
```

### LoginScreen

```text
Tạo LoginScreen cho app MemoQuest.
Cần có: welcome text, 2 text field, nút login, guest hint, validate rỗng, loading state.
UI đẹp, gọn, hiện đại, dễ làm trên Android.
```

### HomeScreen

```text
Tạo HomeScreen cho MemoQuest.
Cần có header chào người dùng, XP/level card, shortcut đến Notes, Flashcards, Quiz, Stats, section streak/reminder.
Dùng layout card mềm, hierarchy rõ, scroll mượt.
```

### NotesScreen

```text
Tạo NotesScreen cho MemoQuest.
Cần có search bar, filter chip môn học, danh sách note dạng card, FAB thêm note, empty state đẹp.
Ưu tiên UI sạch, dễ đọc, dành cho sinh viên.
```

### AddEditNoteScreen

```text
Tạo AddEditNoteScreen cho MemoQuest.
Cần có form title, subject, tags, content, save button, validation, keyboard-safe layout.
UI gọn, tập trung vào nhập liệu nhanh.
```

### NoteDetailScreen

```text
Tạo NoteDetailScreen cho MemoQuest.
Cần có tiêu đề, subject, tags, content, action buttons Edit và Generate Flashcard.
Thiết kế rõ thứ tự thông tin, dễ đọc, có bottom action area.
```

### GenerateFlashcardScreen

```text
Tạo GenerateFlashcardScreen cho MemoQuest.
Cần có preview note, danh sách flashcard được tạo, card question-answer, nút save all.
UI cho cảm giác thông minh, nhanh, gọn.
```

### DeckScreen

```text
Tạo DeckScreen cho MemoQuest.
Cần có deck summary, tổng số thẻ, list flashcard, filter theo mức độ, CTA vào review và quiz.
UI đẹp, card-based, phù hợp mobile.
```

### FlashcardReviewScreen

```text
Tạo FlashcardReviewScreen cho MemoQuest.
Cần có flashcard ở giữa màn hình, flip animation, progress, 3 nút Hard Medium Easy.
Ưu tiên trải nghiệm mượt, tập trung, ít xao nhãng.
```

### QuizScreen

```text
Tạo QuizScreen cho MemoQuest.
Cần có progress, câu hỏi, 4 lựa chọn, trạng thái đã chọn, submit/next button, timer nhẹ nếu cần.
UI cần rõ ràng và dễ chọn đáp án trên mobile.
```

### QuizResultScreen

```text
Tạo QuizResultScreen cho MemoQuest.
Cần có score card, correct/total, XP earned, motivational message, 2 nút Review Again và Back Home.
UI nên tạo cảm giác hoàn thành và tiến bộ.
```

### StatsScreen

```text
Tạo StatsScreen cho MemoQuest.
Cần có tổng note, tổng flashcard, streak, total XP, recent quiz summary, chart placeholder đơn giản.
UI dashboard cần rõ số liệu và đẹp mắt.
```

### SettingsScreen

```text
Tạo SettingsScreen cho MemoQuest.
Cần có dark mode switch, reminder time, clear data, about app.
UI tối giản, sạch, dễ thao tác.
```

## 4. Prompt refine khi UI chưa đẹp

```text
Refine UI này theo hướng premium hơn nhưng vẫn dễ code.
Giữ nguyên logic và widget tree chính.
Cần cải thiện:
- typography rõ hơn
- spacing đều hơn
- card và button có hierarchy tốt hơn
- màu sắc nhất quán hơn
- empty/loading state đẹp hơn
Không thêm package nếu không cần.
```

## 5. Prompt review khi cần tối ưu

```text
Review screen Flutter này theo góc nhìn senior Flutter developer.
Chỉ ra các vấn đề về UI, UX, responsiveness, maintainability, và state handling.
Sau đó sửa trực tiếp code theo hướng gọn hơn, đẹp hơn, logic hơn.
```
