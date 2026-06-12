# MEMOQUEST_PROJECT_GUIDE

## 1. Tổng quan dự án

**Tên project:** MemoQuest - Smart Study Notes & Flashcard RPG

**Mục tiêu:** Xây dựng ứng dụng Android bằng Flutter giúp sinh viên ghi chú, chuyển ghi chú thành flashcard, ôn tập bằng quiz, theo dõi tiến độ học tập, và duy trì động lực bằng cơ chế XP, level, streak.

**Đối tượng người dùng:**
- Sinh viên cần học thuộc nhanh và ôn tập theo chu kỳ
- Người tự học cần một app nhẹ, chạy local, không phụ thuộc server
- Team PRM393 cần một đề tài vừa sức nhưng vẫn có điểm nhấn về UI và logic

**Điểm "wow" của app:**
- Kết hợp học tập và gamification: note -> flashcard -> quiz -> XP -> level
- Hoạt động local bằng SQLite, không cần server riêng
- Có reminder nhắc ôn bài, giúp app không chỉ "lưu ghi chú" mà còn "đẩy người dùng quay lại học"

**Main flow:**

```text
Login
  -> Home
  -> Create Note
  -> Generate Flashcard
  -> Review Flashcard
  -> Quiz
  -> Earn XP
  -> Statistics
```

## 2. Công nghệ sử dụng

| Công nghệ | Mục đích | Vì sao chọn |
| --- | --- | --- |
| Flutter | Xây dựng UI mobile | Một codebase, học được widget, state, navigation |
| Dart | Ngôn ngữ của Flutter | Cú pháp rõ, hỗ trợ async tốt |
| Android only | Giảm phạm vi | Phù hợp môn học, tập trung hoàn thành core features |
| Provider | State management | Dễ học, dễ dùng, đủ cho đồ án môn học |
| SQLite / sqflite | Lưu dữ liệu local | Không cần server, phù hợp note, flashcard, kết quả quiz |
| SharedPreferences | Lưu session và setting nhẹ | Đơn giản cho login mock, theme, onboarding |
| HTTP | Gọi mock API hoặc lấy deck mẫu | Có giá trị học tập nhưng không làm app phức tạp quá |
| flutter_local_notifications | Nhắc ôn bài | Tạo giá trị sử dụng thực tế |
| intl | Format ngày giờ | Hiển thị dữ liệu dễ đọc hơn |

## 3. Kiến thức cần học trước khi code

### Dart fundamentals
- Variables, final, const
- Null safety và cách tránh null crash
- Class, constructor, object
- List, Map, where, map, firstWhere
- Future, async/await
- try/catch, custom exception cơ bản

### Flutter UI
- Hiểu widget tree
- Phân biệt `StatelessWidget` và `StatefulWidget`
- Dùng `Scaffold`, `AppBar`, `BottomNavigationBar`
- Dùng `ListView`, `Card`, `ListTile`
- Dùng `TextField`, `TextFormField`, `Form`, `validator`
- Dùng `Dialog`, `SnackBar`, `BottomSheet`
- Dùng `showDatePicker`

### Navigation
- `Navigator.push`, `pushReplacement`, `pop`
- Truyền argument giữa các screen
- Guarded route: chưa login thì không vào Home

### State management
- `Provider` để cấp state xuống widget tree
- `ChangeNotifier` để thông báo UI cập nhật
- `notifyListeners()` khi data thay đổi
- `setState` chỉ dùng cho state UI cục bộ
- `Provider` dùng cho state cần dùng lại ở nhiều widget

### Local storage
- `SharedPreferences` dùng cho session, dark mode, reminder time
- SQLite dùng cho note, flashcard, quiz result, user progress
- Hiểu CRUD: create, read, update, delete
- Hiểu `database version`, `onCreate`, `onUpgrade`
- Khi đổi schema phải tăng version và viết logic migrate hoặc clear app data trong giai đoạn dev

### Async / API
- `FutureBuilder` cho màn hình lấy dữ liệu bất đồng bộ
- Loading state, error state, empty state
- HTTP GET request cơ bản
- Parse JSON thành model

### Notification
- Local notification là nhắc việc chạy trên thiết bị
- Dùng cho reminder ôn flashcard
- Cần kiểm tra permission trên Android, nhất là Android 13+

### Git / GitHub teamwork
- Tạo branch theo feature
- Viết commit message dễ đọc
- Tạo pull request để review
- Xử lý conflict cẩn thận
- Không code thẳng vào `main`

## 4. Scope chức năng

### Must-have
- [x] Login/logout mock
- [x] Home dashboard
- [x] Notes CRUD
- [x] Flashcard CRUD
- [x] Review flashcard
- [x] Quiz mode
- [x] SQLite local storage
- [x] SharedPreferences session
- [x] Statistics cơ bản

### Should-have
- [ ] Search/filter notes
- [ ] Tag/subject
- [ ] XP, level, streak
- [ ] Notification nhắc ôn
- [ ] Dark mode

### Nice-to-have
- [ ] Auto-generate flashcard từ note bằng rule đơn giản
- [ ] Import/export JSON
- [ ] Public sample decks bằng mock API
- [ ] Badge/achievement

## 5. Danh sách màn hình

| Screen name | Mục đích | Chức năng chính | Người phụ trách gợi ý |
| --- | --- | --- | --- |
| SplashScreen | Kiểm tra session | Delay ngắn, đọc SharedPreferences, route | Người 1 |
| LoginScreen | Đăng nhập mock | Nhập username, validate, save session | Người 1 |
| HomeScreen | Tổng quan học tập | Shortcut đến Notes, Deck, Quiz, Stats | Người 1 |
| NotesScreen | Danh sách ghi chú | List, search, filter, delete | Người 2 |
| AddEditNoteScreen | Tạo/sửa ghi chú | Form, validation, save SQLite | Người 2 |
| NoteDetailScreen | Xem chi tiết note | Nội dung, tag, nút generate flashcard | Người 2 |
| GenerateFlashcardScreen | Tạo flashcard từ note | Tách câu hỏi/đáp án, preview, save | Người 3 |
| DeckScreen | Danh sách flashcard/deck | Xem deck, thêm/sửa/xóa card | Người 3 |
| FlashcardReviewScreen | Ôn tập theo thẻ | Flip card, difficulty, next review | Người 3 |
| QuizScreen | Làm quiz | Chọn đáp án, timer nếu cần | Người 4 |
| QuizResultScreen | Kết quả quiz | Điểm, số câu đúng, XP nhận được | Người 4 |
| StatsScreen | Thống kê học tập | Tổng note, tổng flashcard, streak, chart đơn giản | Người 4 |
| SettingsScreen | Cấu hình | Dark mode, reminder time, clear data | Người 1 |

## 6. Cấu trúc thư mục Flutter đề xuất

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    theme/
    utils/
  data/
    models/
    repositories/
    datasources/
  features/
    auth/
    home/
    notes/
    flashcards/
    quiz/
    stats/
    settings/
  services/
    db/
    notification/
    storage/
```

**Giải thích:**
- `main.dart`: điểm vào của app
- `app.dart`: cấu hình `MaterialApp`, routes, theme
- `core/`: thành phần dùng chung như color, text style, constants, helper
- `data/models/`: model Dart như `Note`, `Flashcard`
- `data/repositories/`: xử lý luồng dữ liệu giữa UI và database
- `data/datasources/`: nếu cần tách truy cập SQLite hoặc mock API
- `features/`: chia theo tính năng để dễ quản lý và chia việc
- `services/db/`: `SQLiteHelper`, migration
- `services/notification/`: local notification
- `services/storage/`: `SharedPreferences`

**Lưu ý:** Không cần dùng Clean Architecture full. Provider + Repository + SQLite Helper là đủ cho đồ án này.

## 7. Database design

### Tổng quan

MemoQuest dùng SQLite vì:
- Database nằm local trong app Android
- Không cần cài server riêng
- Đủ cho note, flashcard, lịch sử quiz, progression

### Bảng `notes`

**Mục đích:** Lưu ghi chú học tập do người dùng tạo.

| Field | Kiểu dữ liệu | Ghi chú |
| --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Khóa chính |
| title | TEXT NOT NULL | Tiêu đề note |
| content | TEXT NOT NULL | Nội dung note |
| subject | TEXT | Môn học / chủ đề |
| tags | TEXT | Có thể lưu CSV hoặc JSON string |
| created_at | TEXT NOT NULL | ISO datetime |
| updated_at | TEXT NOT NULL | ISO datetime |

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  subject TEXT,
  tags TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### Bảng `flashcards`

**Mục đích:** Lưu thẻ học tạo từ note hoặc tạo tay.

| Field | Kiểu dữ liệu | Ghi chú |
| --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Khóa chính |
| note_id | INTEGER | Khóa ngoại tham chiếu `notes.id` |
| question | TEXT NOT NULL | Mặt trước thẻ |
| answer | TEXT NOT NULL | Mặt sau thẻ |
| difficulty | TEXT DEFAULT 'medium' | hard / medium / easy |
| next_review_at | TEXT | Ngày ôn tiếp theo |
| created_at | TEXT NOT NULL | ISO datetime |
| updated_at | TEXT NOT NULL | ISO datetime |

```sql
CREATE TABLE flashcards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  note_id INTEGER,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  difficulty TEXT DEFAULT 'medium',
  next_review_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
);
```

### Bảng `quiz_results`

**Mục đích:** Lưu lịch sử kết quả quiz để thống kê và cộng XP.

| Field | Kiểu dữ liệu | Ghi chú |
| --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Khóa chính |
| deck_name | TEXT | Tên deck hoặc subject |
| total_questions | INTEGER NOT NULL | Tổng số câu |
| correct_answers | INTEGER NOT NULL | Số câu đúng |
| score | REAL NOT NULL | Tỷ lệ hoặc điểm |
| earned_xp | INTEGER NOT NULL | XP nhận được |
| played_at | TEXT NOT NULL | Thời điểm làm quiz |

```sql
CREATE TABLE quiz_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  deck_name TEXT,
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER NOT NULL,
  score REAL NOT NULL,
  earned_xp INTEGER NOT NULL,
  played_at TEXT NOT NULL
);
```

### Bảng `user_progress`

**Mục đích:** Lưu tiến độ tổng hợp của người dùng.

| Field | Kiểu dữ liệu | Ghi chú |
| --- | --- | --- |
| id | INTEGER PRIMARY KEY | Có thể chỉ dùng 1 dòng với id = 1 |
| total_xp | INTEGER NOT NULL DEFAULT 0 | Tổng XP |
| level | INTEGER NOT NULL DEFAULT 1 | Level hiện tại |
| streak_days | INTEGER NOT NULL DEFAULT 0 | Số ngày học liên tiếp |
| last_study_date | TEXT | Ngày học gần nhất |
| total_reviews | INTEGER NOT NULL DEFAULT 0 | Tổng lượt review |
| total_quizzes | INTEGER NOT NULL DEFAULT 0 | Tổng quiz |

```sql
CREATE TABLE user_progress (
  id INTEGER PRIMARY KEY,
  total_xp INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1,
  streak_days INTEGER NOT NULL DEFAULT 0,
  last_study_date TEXT,
  total_reviews INTEGER NOT NULL DEFAULT 0,
  total_quizzes INTEGER NOT NULL DEFAULT 0
);
```

### Bảng `settings`

**Mục đích:** Lưu setting nếu muốn đưa một phần từ `SharedPreferences` sang SQLite. Có thể bỏ qua bảng này nếu app đơn giản.

| Field | Kiểu dữ liệu | Ghi chú |
| --- | --- | --- |
| key | TEXT PRIMARY KEY | Tên setting |
| value | TEXT | Giá trị string |

```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT
);
```

### Giải thích thiết kế

- `notes` liên kết với `flashcards` bằng `note_id` vì một note có thể sinh ra nhiều flashcard.
- `quiz_results` tách riêng để lưu lịch sử mỗi lần làm bài. Nếu nhập chung vào `user_progress` sẽ mất chi tiết từng lần quiz.
- `user_progress` lưu `XP`, `level`, `streak` vì đây là state tổng hợp, truy vấn nhanh cho Home và Stats.
- Khi đổi schema database:
  - Tăng `database version`
  - Viết `onUpgrade` để migrate
  - Trong giai đoạn dev có thể clear app data nếu schema thay đổi nhiều

## 8. Model classes

### Note

**Field đề xuất:** `id`, `title`, `content`, `subject`, `tags`, `createdAt`, `updatedAt`

**Ý nghĩa:** Đại diện cho một ghi chú học tập.

```dart
class Note {
  final int? id;
  final String title;
  final String content;
  final String? subject;
  final String? tags;
  final String createdAt;
  final String updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.subject,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        subject: map['subject'],
        tags: map['tags'],
        createdAt: map['created_at'],
        updatedAt: map['updated_at'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'subject': subject,
        'tags': tags,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
```

### Flashcard

**Field đề xuất:** `id`, `noteId`, `question`, `answer`, `difficulty`, `nextReviewAt`, `createdAt`, `updatedAt`

**Ý nghĩa:** Đại diện cho một thẻ học.

### QuizResult

**Field đề xuất:** `id`, `deckName`, `totalQuestions`, `correctAnswers`, `score`, `earnedXp`, `playedAt`

**Ý nghĩa:** Đại diện cho kết quả mỗi lần làm quiz.

### UserProgress

**Field đề xuất:** `id`, `totalXp`, `level`, `streakDays`, `lastStudyDate`, `totalReviews`, `totalQuizzes`

**Ý nghĩa:** Lưu tổng quan tiến độ của người dùng.

## 9. App flow chi tiết

### Login flow

```text
App start
  -> SplashScreen
  -> Kiểm tra isLoggedIn trong SharedPreferences
      -> false: LoginScreen
      -> true: HomeScreen
```

### Note flow

```text
NotesScreen
  -> AddEditNoteScreen
  -> Save vào SQLite
  -> Quay lại NotesScreen
  -> Hiển thị item mới
  -> Bấm vào item
  -> NoteDetailScreen
```

### Flashcard flow

```text
NoteDetailScreen
  -> GenerateFlashcardScreen
  -> Tạo danh sách flashcard
  -> Save vào SQLite
  -> DeckScreen
  -> FlashcardReviewScreen
```

### Quiz flow

```text
DeckScreen / HomeScreen
  -> Chọn deck
  -> QuizScreen
  -> Submit answer
  -> QuizResultScreen
  -> Lưu quiz_results
  -> Cập nhật user_progress
```

### Review flow

**Rule đề xuất:**
- Hard -> review lại sau 1 ngày
- Medium -> review lại sau 3 ngày
- Easy -> review lại sau 7 ngày

```text
Review card
  -> Chọn difficulty
  -> Tính next_review_at
  -> Update flashcard
  -> Tăng total_reviews
```

## 10. Chia việc cho team 4 người

| Người | Nhiệm vụ | File / folder phụ trách | Output cần hoàn thành | Rủi ro cần tránh |
| --- | --- | --- | --- | --- |
| Người 1 | Auth, Splash, Home, Settings, SharedPreferences | `features/auth`, `features/home`, `features/settings`, `services/storage` | Login mock, route logic, settings hoạt động | Save session sai, route lặp, UI home rối |
| Người 2 | Notes CRUD, search/filter, note detail, validation | `features/notes`, một phần `data/repositories` | Notes thêm/sửa/xóa/tìm kiếm được | Form không validate, query SQLite sai |
| Người 3 | Flashcard CRUD, generate flashcard, review, flip card UI | `features/flashcards` | Deck + review flow đầy đủ | UI flip card giật, logic next review sai |
| Người 4 | Quiz, statistics, XP/level/streak, notification, SQLite helper | `features/quiz`, `features/stats`, `services/db`, `services/notification` | Quiz chạy, thống kê cập nhật, DB helper ổn định | DB schema đổi liên tục, notification lỗi permission |

**Quy ước phối hợp:**
- Mỗi người làm đúng folder của mình
- Nếu sửa file dùng chung như `app.dart`, thông báo trước trong group
- Merge nhanh, nhỏ, dễ review

## 11. Coding rules

- Đặt tên file theo `snake_case`
- Đặt tên class theo `PascalCase`
- Đặt tên variable, function theo `camelCase`
- Không để logic database trong UI screen
- Widget quá dài thì tách widget con
- Tạo reusable widget cho card, button, empty state
- Validate input trước khi save
- Bắt lỗi khi gọi database/API
- Hạn chế hardcode text, có thể tách `constants`
- Mỗi screen cần có loading state, empty state, error state nếu cần

## 12. Git workflow

### Branch đề xuất
- `main`
- `develop`
- `feature/auth`
- `feature/notes`
- `feature/flashcards`
- `feature/quiz-stats`

### Quy tắc commit
- `feat:`
- `fix:`
- `refactor:`
- `docs:`
- `style:`

### Ví dụ commit message
- `feat: add login mock with shared preferences session`
- `feat: implement notes crud with sqlite`
- `fix: handle empty flashcard review state`
- `refactor: split home dashboard widgets`
- `docs: add memoquest project guide`

### Quy trình đề xuất

```text
Create branch
  -> Code feature
  -> Test local
  -> Commit nhỏ, rõ nghĩa
  -> Push branch
  -> Pull request vào develop
  -> Review
  -> Merge
```

## 13. Milestone plan

| Milestone | Nội dung | Kết quả mong đợi |
| --- | --- | --- |
| 1 | Setup project, theme, folder structure, navigation | App chạy được, route cơ bản ổn định |
| 2 | Auth + Home + Settings | Vào được app, có dashboard và setting |
| 3 | Notes CRUD + SQLite | Thêm/sửa/xóa note, dữ liệu lưu local |
| 4 | Flashcards + Review | Tạo thẻ học và ôn tập được |
| 5 | Quiz + XP + Statistics | Quiz chạy, tính điểm, hiện thống kê |
| 6 | Notification + polish UI + testing | Reminder chạy, UI đồng bộ, giảm bug |
| 7 | Prepare presentation + demo script | Có slide, demo 3-5 phút, chia phần defense |

## 14. Testing checklist

- [ ] Login/logout đúng flow
- [ ] Add note thành công
- [ ] Edit note đúng dữ liệu
- [ ] Delete note đúng item
- [ ] Search note trả kết quả đúng
- [ ] Generate flashcard không lỗi
- [ ] Review flashcard cập nhật difficulty
- [ ] Quiz tính score đúng
- [ ] XP cập nhật sau quiz/review
- [ ] Streak cập nhật theo ngày
- [ ] Notification tạo được reminder
- [ ] Restart app vẫn còn dữ liệu
- [ ] Clear data reset đúng
- [ ] Database rỗng không crash

## 15. Presentation guide

### Cấu trúc thuyết trình
1. Problem: học thuộc khó, ghi chú rời rạc, dễ quên
2. Solution: MemoQuest kết hợp note, flashcard, quiz, reminder
3. Main features: notes, flashcards, quiz, stats, XP
4. Technical architecture: Flutter + Provider + SQLite + SharedPreferences
5. Database design: 4-5 bảng chính và quan hệ
6. Demo flow: login -> tạo note -> tạo flashcard -> quiz -> stats
7. Team contribution: mỗi người một module
8. Challenges: schema, state, merge code, UI consistency
9. Future improvement: cloud sync, AI generate flashcard, social sharing

### Demo script ngắn 3-5 phút

```text
Xin chào thầy/các bạn, nhóm em giới thiệu MemoQuest - ứng dụng hỗ trợ học tập trên Android.
Vấn đề là sinh viên thường ghi chú nhiều nhưng ôn tập không đều, dễ quên kiến thức.
MemoQuest giải quyết bằng cách cho phép tạo note, chuyển note thành flashcard, làm quiz và theo dõi tiến độ học.
Đây là login mock để vào app nhanh. Ở Home, người dùng thấy tổng quan và các lối tắt.
Tại Notes, người dùng tạo ghi chú mới, mở chi tiết, sau đó generate flashcard.
Tại màn review, người dùng lật thẻ và đánh dấu độ khó để hệ thống nhắc ôn lại.
Tại Quiz, người dùng làm bài, nhận điểm và được cộng XP.
Tại Stats, app hiện tổng note, tổng flashcard, streak và kết quả học tập.
App dùng Flutter, Provider, SQLite nên chạy local, không cần server riêng.
Cảm ơn thầy/các bạn, nhóm em sẵn sàng demo và trả lời câu hỏi.
```

## 16. Risk management

| Rủi ro | Tác động | Cách xử lý |
| --- | --- | --- |
| Database schema đổi liên tục | Lỗi migration, mất dữ liệu test | Chốt schema sớm, tăng version, viết `onUpgrade`, clear data khi cần trong dev |
| Conflict Git | Mất code, trễ tiến độ | Chia file rõ, pull thường xuyên, merge nhỏ |
| UI xấu hoặc thiếu nhất quán | App giảm điểm trình bày | Dùng chung color, spacing, component |
| Notification lỗi permission | Reminder không chạy | Test trên Android thật, xử lý permission sớm |
| Thành viên làm trùng file | Dễ conflict | Chia theo feature, thông báo trước khi sửa file dùng chung |
| Không kịp API | Trễ milestone | Mock local trước, HTTP chỉ là phần phụ |

## 17. Final checklist trước khi nộp

- [ ] App chạy được trên Android emulator/device
- [ ] Không crash trong flow chính
- [ ] CRUD hoạt động đúng
- [ ] Database lưu được dữ liệu
- [ ] Có ít nhất 8-10 màn hình
- [ ] Navigation rõ ràng
- [ ] Có validation form
- [ ] Có statistics
- [ ] Có notification hoặc mock notification
- [ ] Có `README.md`
- [ ] Có slide/report nếu cần
- [ ] Mỗi thành viên nắm rõ phần của mình để defense

## 18. Mẫu README.md ngắn

```md
# MemoQuest - Smart Study Notes & Flashcard RPG

## Team Members
- Member 1
- Member 2
- Member 3
- Member 4

## Features
- Login/logout mock
- Notes CRUD
- Flashcard CRUD
- Review flashcard
- Quiz
- XP, level, streak
- Statistics
- Notification reminder

## Tech Stack
- Flutter
- Dart
- Provider
- SQLite / sqflite
- SharedPreferences

## How To Run
1. flutter pub get
2. flutter run

## Demo Account
- Username: demo
- Password: 123456

## Folder Structure
- `lib/core`
- `lib/data`
- `lib/features`
- `lib/services`

## Screenshots
- Home screen
- Notes screen
- Flashcard screen
- Quiz screen
```

## Kết luận

MemoQuest là đề tài vừa sức cho team 4 người nếu giữ phạm vi hợp lý. Ưu tiên hoàn thành flow chính, SQLite, Provider, và UI nhất quán trước. Không nên mở rộng quá sớm sang AI, backend, hoặc architecture quá phức tạp.
