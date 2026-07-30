# 07_Architecture_Design.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Approved

---

# 1. Mục tiêu

Tài liệu này mô tả kiến trúc kỹ thuật tổng thể của ứng dụng.

Kiến trúc được thiết kế theo các tiêu chí:

- Offline First
- Dễ bảo trì
- Dễ mở rộng
- Dễ kiểm thử
- Dễ đọc
- Dữ liệu an toàn
- Có thể phát triển nhiều năm

Ứng dụng ưu tiên tính ổn định và khả năng mở rộng hơn là tối ưu sớm.

---

# 2. Công nghệ sử dụng

| Thành phần | Công nghệ |
|------------|-----------|
| Framework | Flutter |
| Ngôn ngữ | Dart |
| Local Database | SQLite |
| ORM | Drift |
| State Management | Riverpod |
| Navigation | GoRouter |
| Dependency Injection | Riverpod Provider |
| Backup | Local + Google Drive |
| Logging | Logger |
| JSON | json_serializable |
| DateTime | intl |
| Secure Storage | flutter_secure_storage |

---

# 3. Kiến trúc tổng thể

Ứng dụng sử dụng mô hình:

Feature First + Clean Architecture

```
Application

│

├── app

├── core

├── shared

└── features
```

Mỗi Feature hoạt động độc lập.

Các Feature chỉ giao tiếp thông qua Domain Layer.

Không được truy cập trực tiếp Database từ UI.

---

# 4. Các tầng của hệ thống

```
Presentation

↓

Application

↓

Domain

↓

Data

↓

Database
```

---

# 5. Presentation Layer

Bao gồm:

- Screen
- Widget
- Bottom Sheet
- Dialog
- Provider

Chỉ có nhiệm vụ:

- Hiển thị dữ liệu
- Nhận thao tác người dùng
- Gọi Use Case

Không chứa Business Logic.

---

# 6. Application Layer

Là tầng điều phối.

Ví dụ

```
Người dùng

↓

Nhấn Lưu

↓

Validate

↓

Gọi UseCase

↓

Nhận kết quả

↓

Cập nhật UI
```

Application Layer không làm việc trực tiếp với Database.

---

# 7. Domain Layer

Đây là tầng quan trọng nhất.

Bao gồm:

- Entity
- Repository Interface
- Use Case
- Business Rule

Ví dụ

```
SaleUseCase

TransactionUseCase

BackupUseCase

DebtUseCase
```

Toàn bộ nghiệp vụ đều nằm tại đây.

---

# 8. Data Layer

Bao gồm

- Repository
- Local Data Source
- Backup Service

Nhiệm vụ

- Đọc dữ liệu
- Ghi dữ liệu
- Chuyển đổi Model

Không xử lý giao diện.

---

# 9. Database Layer

Sử dụng:

SQLite + Drift

Ưu điểm

- Offline
- Type-safe
- Migration tốt
- Compile-time checking
- Hiệu năng cao

Database là nguồn dữ liệu duy nhất.

Single Source of Truth.

---

# 10. Offline First

Mọi thao tác:

- Bán hàng
- Thu
- Chi
- Kho
- Công nợ

đều ghi trực tiếp vào Database.

Không phụ thuộc Internet.

Internet chỉ dùng cho:

- Sao lưu
- Khôi phục
- Đồng bộ Google Drive

---

# 11. State Management

Sử dụng Riverpod.

Lý do

- Dễ test.
- Không phụ thuộc BuildContext.
- Hiệu năng cao.
- Ít boilerplate.
- Dễ mở rộng.

Quy tắc

Screen

↓

Provider

↓

UseCase

↓

Repository

↓

Database

---

# 12. Navigation

Sử dụng GoRouter.

Ưu điểm

- Quản lý route tập trung.
- Deep Link.
- Nested Navigation.
- Dễ bảo trì.

---

# 13. Repository Pattern

Không cho phép UI đọc Database.

Luồng bắt buộc

```
UI

↓

Provider

↓

UseCase

↓

Repository

↓

Local DataSource

↓

Database
```

Repository chịu trách nhiệm:

- CRUD
- Cache
- Đồng bộ
- Backup

---

# 14. Dependency Injection

Sử dụng Riverpod Provider.

Không dùng Singleton tự tạo.

Không dùng biến Global.

---

# 15. Logging

Mọi thao tác quan trọng đều ghi Log.

Ví dụ

- Thêm giao dịch
- Sửa giao dịch
- Xóa giao dịch
- Sao lưu
- Khôi phục
- Đồng bộ

Không ghi dữ liệu nhạy cảm.

---

# 16. Bảo mật

Database được mã hóa.

Đề xuất

SQLCipher.

Khóa mã hóa lưu trong:

flutter_secure_storage

Không lưu khóa trong mã nguồn.

---

# 17. Backup Engine

Quy trình

```
Database

↓

Đóng Database

↓

Tạo Snapshot

↓

Nén

↓

Mã hóa

↓

Lưu vào bộ nhớ máy

↓

Có Internet ?

     │

 ┌───┴────┐

 │        │

Có      Không

 │        │

 ▼        ▼

Upload  Queue

Google

Drive
```

Nếu Upload thất bại

↓

Retry tự động.

---

# 18. Feature First

Mỗi tính năng là một Module độc lập.

Ví dụ

```
features/

home/

sale/

transaction/

inventory/

customer/

supplier/

debt/

report/

backup/

settings/
```

Không được tạo thư mục chung chứa toàn bộ Screen hoặc Repository.

---

# 19. Cấu trúc thư mục

```
lib/

app/

    router/

    theme/

    config/

    bootstrap/

core/

    database/

    backup/

    security/

    services/

    logger/

    widgets/

    utils/

shared/

    constants/

    extensions/

    design_system/

    models/

features/

    home/

    sale/

    transaction/

    inventory/

    customer/

    supplier/

    debt/

    report/

    backup/

    settings/
```

---

# 20. Cấu trúc một Feature

Ví dụ

```
sale/

data/

    datasource/

    models/

    repository/

domain/

    entities/

    repositories/

    usecases/

presentation/

    screens/

    widgets/

    providers/

routes/

sale_route.dart
```

Mỗi Feature có đầy đủ:

- Data
- Domain
- Presentation

Không phụ thuộc Feature khác.

---

# 21. Error Handling

Không hiển thị Exception.

Ví dụ

Sai

```
SQLiteException...
```

Đúng

```
Không thể lưu dữ liệu.
```

Toàn bộ lỗi phải xử lý tập trung.

---

# 22. Performance

Không đọc toàn bộ Database.

Sử dụng:

- Pagination
- Lazy Loading
- Query tối ưu

Tìm kiếm thực hiện tại Database.

Không lọc dữ liệu bằng UI.

---

# 23. Testing Strategy

Unit Test

- UseCase
- Repository
- Formatter

Integration Test

- Drift Database
- Backup
- Restore

Widget Test

- Form
- Card
- Danh sách

---

# 24. Quy tắc mở rộng

Kiến trúc phải hỗ trợ mở rộng:

- Nhiều loại hàng
- Nhiều cửa hàng
- Nhiều người dùng
- Đồng bộ Cloud
- In hóa đơn
- Máy quét QR
- Thống kê nâng cao

Không cần thay đổi kiến trúc.

---

# 25. Coding Convention

Tên Class

PascalCase

Tên biến

camelCase

Tên file

snake_case

Không viết tắt.

Ví dụ

Đúng

customer_repository.dart

Sai

cus_repo.dart

---

# 26. Nguyên tắc phát triển

Không Hard Code.

Không Duplicate Code.

Không Business Logic trong UI.

Không Query Database trong Widget.

Mỗi Function chỉ làm một việc.

Mỗi Class chỉ có một trách nhiệm.

Ưu tiên Composition hơn Inheritance.

---

# 27. Kết luận

Kiến trúc của dự án được lựa chọn là:

Feature First

+

Clean Architecture

+

Riverpod

+

Drift

+

SQLite

+

Offline First

Kiến trúc này đảm bảo:

- Dễ bảo trì
- Dễ mở rộng
- Dễ kiểm thử
- Dễ phát triển lâu dài
- Đảm bảo an toàn dữ liệu
- Phù hợp cho ứng dụng thực tế sử dụng hằng ngày.
