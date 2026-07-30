# 08_Architecture_Design.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Mục tiêu

Tài liệu này mô tả kiến trúc Flutter của ứng dụng.

Mục tiêu:

- Dễ bảo trì.
- Dễ mở rộng.
- Ít phụ thuộc giữa các module.
- Dễ kiểm thử.
- Có thể thêm tính năng mà không ảnh hưởng phần khác.

---

# 2. Kiến trúc tổng thể

Ứng dụng sử dụng:

```
Presentation

↓

Application (Use Cases)

↓

Domain

↓

Infrastructure (Repository)

↓

Local Database (Drift)
```

Nguyên tắc:

- UI không truy cập Database trực tiếp.
- UI chỉ gọi Use Case.
- Use Case gọi Repository.
- Repository làm việc với Drift.

---

# 3. Công nghệ sử dụng

| Thành phần | Công nghệ |
|------------|-----------|
| UI | Flutter Material 3 |
| State Management | Riverpod |
| Routing | GoRouter |
| Database | Drift (SQLite) |
| Dependency Injection | Riverpod Provider |
| JSON | json_serializable |
| Logging | logger |
| Backup | Google Drive API + Local Storage |
| Localization | intl |

---

# 4. Cấu trúc thư mục

```text
lib/

├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── constants/
│
├── core/
│   ├── database/
│   ├── services/
│   ├── errors/
│   ├── utils/
│   ├── extensions/
│   ├── widgets/
│   └── providers/
│
├── features/
│   ├── dashboard/
│   ├── customers/
│   ├── products/
│   ├── sales/
│   ├── inventory/
│   ├── transactions/
│   ├── debts/
│   ├── suppliers/
│   ├── backup/
│   └── settings/
│
└── main.dart
```

---

# 5. Cấu trúc Feature

Ví dụ feature Customer.

```text
customers/

├── presentation/
│
├── application/
│
├── domain/
│
├── infrastructure/
│
└── widgets/
```

---

## Presentation

Chứa:

- Screen
- Dialog
- Bottom Sheet
- Controller (nếu cần)

---

## Application

Chứa:

- Use Case
- Service nghiệp vụ

Ví dụ

```
CreateCustomerUseCase
```

```
UpdateCustomerUseCase
```

---

## Domain

Chứa:

- Entity
- Repository Interface
- Business Rule

Ví dụ

```
Customer
```

```
CustomerRepository
```

---

## Infrastructure

Chứa:

- Drift DAO
- Repository Implementation
- Mapper
- DTO

---

## Widgets

Widget dùng riêng của feature.

Ví dụ

```
CustomerCard
```

---

# 6. Quy tắc Dependency

Presentation

↓

Application

↓

Domain

↓

Infrastructure

Không được gọi ngược.

Ví dụ:

Infrastructure

❌ Không được gọi UI.

---

# 7. State Management

Sử dụng Riverpod.

Nguyên tắc:

- Một màn hình = một Provider chính.
- Không sử dụng Provider toàn cục nếu không cần.
- Dữ liệu chỉ được cập nhật thông qua Use Case.

Ví dụ:

```
CustomerListProvider
```

```
DashboardProvider
```

```
InventoryProvider
```

---

# 8. Routing

Sử dụng GoRouter.

Ví dụ:

```text
/

Dashboard

/customers

/customers/detail

/products

/sales

/debts

/settings

/backup
```

Không sử dụng Navigator.push trực tiếp.

---

# 9. Repository Pattern

Presentation

↓

Use Case

↓

Repository

↓

Drift

Ví dụ

```
CustomerRepository
```

```
ProductRepository
```

```
TransactionRepository
```

---

# 10. Use Case Pattern

Một Use Case chỉ thực hiện một nhiệm vụ.

Ví dụ:

```
CreateSaleUseCase
```

↓

Tạo phiếu bán.

Không thực hiện:

- Backup.
- Đồng bộ.
- In báo cáo.

---

# 11. Drift

Drift chỉ làm:

- CRUD.
- Query.
- Transaction.

Không chứa Business Logic.

---

# 12. Mapper

Không truyền trực tiếp DTO lên UI.

Ví dụ

```
CustomerTable

↓

CustomerDto

↓

Customer Entity

↓

UI
```

---

# 13. Logging

Mọi lỗi quan trọng đều ghi log.

Ví dụ:

- Backup lỗi.
- Restore lỗi.
- Database lỗi.
- Migration lỗi.

Không ghi log thông tin nhạy cảm.

---

# 14. Error Handling

Tất cả lỗi được chuyển thành dạng thống nhất.

Ví dụ

```
DatabaseFailure
```

```
ValidationFailure
```

```
BackupFailure
```

UI chỉ hiển thị thông báo thân thiện.

Ví dụ:

```
Không thể lưu dữ liệu.

Vui lòng thử lại.
```

---

# 15. Shared Widgets

Các Widget dùng chung đặt trong:

```
core/widgets
```

Ví dụ:

- PrimaryButton
- AppCard
- AppTextField
- ConfirmDialog
- EmptyView
- LoadingView

Không tạo nhiều phiên bản giống nhau.

---

# 16. Theme

Toàn bộ ứng dụng dùng một Theme chung.

Bao gồm:

- Màu sắc.
- Font.
- Border Radius.
- Padding.
- Shadow.
- Button Style.

Không đặt màu trực tiếp trong Widget.

---

# 17. Constants

Các giá trị cố định đặt trong:

```
app/constants
```

Ví dụ:

- App Colors
- App Strings
- Date Format
- Currency Format
- Animation Duration

---

# 18. Quy tắc đặt tên

Class

PascalCase

Ví dụ

```
CreateSaleUseCase
```

---

Biến

camelCase

Ví dụ

```
customerName
```

---

File

snake_case

Ví dụ

```
customer_repository.dart
```

---

Provider

Kết thúc bằng

```
Provider
```

Ví dụ

```
dashboardProvider
```

---

Use Case

Kết thúc bằng

```
UseCase
```

Ví dụ

```
BackupDatabaseUseCase
```

---

Repository

Kết thúc bằng

```
Repository
```

---

# 19. Quy tắc kiểm thử

Use Case phải có Unit Test.

Repository có Integration Test.

Widget quan trọng có Widget Test.

Không bắt buộc test cho màn hình đơn giản.

---

# 20. Bảo mật Database

Database SQLite được mã hoá.

Đề xuất

```
SQLCipher
```

Khoá mã hoá lưu trong

```
flutter_secure_storage
```

Không lưu khoá trong mã nguồn.

Đây là mã hoá **tại chỗ (at rest)** của file `.sqlite`, khác với mã hoá bản sao lưu (AES-256) được mô tả trong `10_Data_Protection.md`. Hai lớp mã hoá này độc lập với nhau.

---

# 21. Tổng kết

Kiến trúc Flutter của dự án được xây dựng theo các nguyên tắc:

- Feature First.
- Clean Architecture.
- Repository Pattern.
- Riverpod.
- GoRouter.
- Drift.
- Material 3.
- Tách biệt UI và Business Logic.
- Dễ mở rộng, dễ kiểm thử và dễ bảo trì trong thời gian dài.
