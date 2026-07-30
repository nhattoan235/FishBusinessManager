# 08_Naming_Convention.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Approved

---

# 1. Mục tiêu

Tài liệu này quy định cách đặt tên trong toàn bộ dự án.

Mục tiêu:

- Đồng nhất.
- Dễ đọc.
- Dễ tìm kiếm.
- Dễ mở rộng.
- Phù hợp chuẩn Flutter và Clean Architecture.

Mọi thành phần trong dự án phải tuân thủ tài liệu này.

---

# 2. Ngôn ngữ

Toàn bộ tên trong mã nguồn sử dụng tiếng Anh.

Không sử dụng tiếng Việt trong:

- Class
- File
- Folder
- Database
- API
- Enum
- Constant

Tiếng Việt chỉ sử dụng trên giao diện người dùng.

---

# 3. Quy tắc chung

Tên phải:

- Rõ nghĩa.
- Không viết tắt.
- Không dùng ký tự đặc biệt.
- Không dùng khoảng trắng.

Ví dụ

Đúng

CustomerRepository

Sai

CusRepo

---

# 4. Quy tắc thư mục

Tên thư mục sử dụng:

snake_case

Ví dụ

```
customer

sale

transaction

inventory

backup

settings
```

---

# 5. Quy tắc File

Tên file:

snake_case

Ví dụ

```
customer_repository.dart

sale_use_case.dart

transaction_card.dart

backup_service.dart
```

Không viết hoa.

---

# 6. Quy tắc Class

Class

PascalCase

Ví dụ

```
Customer

CustomerRepository

TransactionCard

BackupService
```

---

# 7. Quy tắc Biến

Biến

camelCase

Ví dụ

```
customerName

currentBalance

totalIncome

backupPath
```

---

# 8. Quy tắc Constant

Sử dụng camelCase với tiền tố thể hiện nhóm hoặc static const theo chuẩn Dart.

Ví dụ

```dart
static const double defaultPadding = 16;
static const int maxBackupFiles = 50;
```

Hoặc

```dart
const appName = "Fish Business Manager";
```

Không sử dụng:

```dart
DEFAULT_PADDING
```

---

# 9. Quy tắc Enum

Enum

PascalCase

Ví dụ

```
TransactionType

BackupStatus

PaymentStatus

InventorySource
```

Giá trị Enum

camelCase

Ví dụ

```
income

expense

pending

completed

cancelled
```

---

# 10. Quy tắc Database

Tên bảng

snake_case

Ví dụ

```
customers

suppliers

transactions

inventory_entries

debts

backup_logs
```

Không dùng

```
tbl_customer
```

---

Tên cột

snake_case

Ví dụ

```
customer_id

created_at

updated_at

transaction_date

transaction_time
```

---

Khóa chính

```
id
```

---

Khóa ngoại

```
customer_id

supplier_id

transaction_id
```

---

# 11. Quy tắc Entity

Entity

Tên số ít.

Ví dụ

```
Customer

Supplier

Transaction

InventoryEntry

Debt
```

---

# 12. Quy tắc Model

Tên Model

Thêm hậu tố

Model

Ví dụ

```
CustomerModel

TransactionModel

BackupModel
```

---

# 13. Quy tắc Repository

Interface

```
CustomerRepository
```

Triển khai

```
CustomerRepositoryImpl
```

---

# 14. Quy tắc Use Case

Tên phải bắt đầu bằng động từ.

Ví dụ

```
CreateSaleUseCase

RecordTransactionUseCase

CollectDebtUseCase

RestoreBackupUseCase

GenerateReportUseCase
```

Không dùng

```
SaleManager
```

---

# 15. Quy tắc Provider

Hậu tố

Provider

Ví dụ

```
customerProvider

saleProvider

backupProvider
```

---

# 16. Quy tắc Widget

Widget kết thúc bằng:

Card

Tile

Dialog

Sheet

Button

Screen

Ví dụ

```
TransactionCard

CustomerTile

BackupDialog

QuickActionButton

HomeScreen
```

---

# 17. Quy tắc Route

Tên route

camelCase

Ví dụ

```
homeRoute

saleRoute

backupRoute
```

Đường dẫn

```
/

sale

transaction

backup
```

---

# 18. Quy tắc Service

Tên kết thúc bằng

Service

Ví dụ

```
BackupService

DriveService

EncryptionService

NotificationService
```

---

# 19. Quy tắc Data Source

Ví dụ

```
CustomerLocalDataSource

TransactionLocalDataSource
```

Nếu sau này có Cloud

```
CustomerRemoteDataSource
```

---

# 20. Quy tắc Logger

Tên

LoggerService

Không tạo nhiều Logger khác nhau.

---

# 21. Quy tắc Design System

Màu sắc

```
AppColors
```

Typography

```
AppTypography
```

Spacing

```
AppSpacing
```

Radius

```
AppRadius
```

Animation

```
AppDurations
```

Theme

```
AppTheme
```

---

# 22. Quy tắc Asset

Ảnh

```
assets/images/
```

Icon

```
assets/icons/
```

Font

```
assets/fonts/
```

Animation

```
assets/animations/
```

Backup

```
backups/
```

---

# 23. Quy tắc trạng thái

Không dùng Boolean nếu có nhiều hơn hai trạng thái.

Ví dụ

Đúng

```dart
enum BackupStatus {
  pending,
  uploading,
  completed,
  failed,
}
```

Sai

```dart
bool isBackup;
bool isUploading;
```

---

# 24. Quy tắc DateTime

Trong Database

```
created_at

updated_at

deleted_at
```

Trong Dart

```
createdAt

updatedAt

deletedAt
```

---

# 25. Quy tắc ID

Tất cả Entity đều có

```
id
```

Không dùng

```
customerId

supplierId
```

làm khóa chính.

Khóa ngoại mới dùng:

```
customer_id

supplier_id
```

---

# 26. Quy tắc đặt tên giao dịch

Thu

```
income
```

Chi

```
expense
```

Không dùng

```
moneyIn

moneyOut
```

---

# 27. Quy tắc Commit Git

Định dạng

```
type(scope): message
```

Ví dụ

```
feat(transaction): add quick transaction screen

fix(backup): retry upload to Google Drive

refactor(customer): simplify search logic

docs(architecture): update repository pattern

test(report): add monthly report tests
```

Các loại commit

- feat
- fix
- refactor
- docs
- test
- chore
- style

---

# 28. Quy tắc đặt tên Backup

Định dạng

```
fish_business_backup_YYYYMMDD_HHmmss.zip
```

Ví dụ

```
fish_business_backup_20260730_093000.zip
```

---

# 29. Quy tắc Migration

Tên Migration

```
migration_v1.dart

migration_v2.dart

migration_v3.dart
```

Không sửa Migration cũ sau khi phát hành.

---

# 30. Quy tắc Documentation

Tên tài liệu

```
01_Business_Analysis.md

02_UseCase_Specification.md

03_Business_Rules.md

...

09_Database_Design.md
```

Luôn đánh số thứ tự.

---

# 31. Quy tắc mở rộng

Nếu sau này bổ sung tính năng mới:

- Tên phải theo cùng quy tắc.
- Không tạo ngoại lệ.
- Không viết tắt.
- Không đổi tên thành phần đã phát hành nếu không thật sự cần thiết.

---

# 32. Kết luận

Naming Convention là nền tảng giúp toàn bộ mã nguồn nhất quán, dễ đọc và dễ bảo trì.

Mọi thành viên tham gia dự án phải tuân thủ tài liệu này để đảm bảo chất lượng và khả năng mở rộng của hệ thống trong tương lai.
