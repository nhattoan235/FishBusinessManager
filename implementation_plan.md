# Kế hoạch Xây dựng Ứng dụng Fish Business Manager

## Tổng quan dự án

Xây dựng ứng dụng Flutter quản lý hoạt động buôn bán chứng nước cho hộ kinh doanh gia đình.
Ứng dụng hoạt động **offline-first**, dữ liệu lưu cục bộ trên điện thoại Android, sao lưu Google Drive.
Kiến trúc theo chuẩn **Clean Architecture + Feature First + Riverpod + Drift + GoRouter**.

## Vị trí dự án

- **Thư mục gốc**: `d:\Canhan\Doan\FishBusinessManager\FishExpenseManager\mobile\`
- **Package hiện tại**: Mới tạo, chỉ có `main.dart` mặc định của Flutter
- **Target platform**: Android (chính), iOS (phụ)

---

## Open Questions

> [!IMPORTANT]
> **Câu hỏi 1 — Tên package:**
> Hiện tại `pubspec.yaml` đang để `name: mobile`. Tôi sẽ đổi thành `fish_business_manager`. Bạn có đồng ý không?

> [!IMPORTANT]
> **Câu hỏi 2 — Phạm vi xây dựng trong kế hoạch này:**
> Do dự án rất lớn, tôi đề xuất chia thành **4 giai đoạn**. Bạn muốn thực hiện tất cả ngay, hay chỉ từng giai đoạn một?

> [!NOTE]
> **Câu hỏi 3 — Database encryption:**
> Tài liệu yêu cầu mã hóa SQLite bằng SQLCipher (`flutter_secure_storage`). Giai đoạn 1 có thể bỏ qua encryption để đơn giản, thêm vào sau? Hay bạn muốn bắt đầu với encryption ngay?

> [!NOTE]
> **Câu hỏi 4 — Google Drive Backup:**
> Tính năng này yêu cầu OAuth2 với Google. Có thể để giai đoạn cuối. Bạn đồng ý không?

---

## Công nghệ sử dụng

| Thành phần | Package | Phiên bản |
|------------|---------|-----------|
| State Management | `flutter_riverpod` | ^2.x |
| Routing | `go_router` | ^14.x |
| Database ORM | `drift` + `drift_flutter` | ^2.x |
| Code Generation | `build_runner` + `drift_dev` | latest |
| UUID | `uuid` | ^4.x |
| Date Format | `intl` | ^0.19 |
| Logger | `logger` | ^2.x |
| Secure Storage | `flutter_secure_storage` | ^9.x |
| Archive/Zip | `archive` | ^3.x |
| Crypto/SHA256 | `crypto` | ^3.x |
| Google Sign In | `google_sign_in` | ^6.x (Giai đoạn 4) |
| Google Drive API | `googleapis` | ^13.x (Giai đoạn 4) |
| Path Provider | `path_provider` | ^2.x |
| Shared Preferences | `shared_preferences` | ^2.x |

---

## Cấu trúc thư mục đích

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Root widget
│   ├── router/
│   │   └── app_router.dart         # GoRouter config
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_theme.dart
│   └── constants/
│       └── app_constants.dart
│
├── core/
│   ├── database/
│   │   ├── app_database.dart       # Drift AppDatabase
│   │   ├── tables/                 # 15 table definitions
│   │   ├── dao/                    # DAO cho từng feature
│   │   ├── migrations/             # Migration files
│   │   ├── seeds/                  # Seed data
│   │   └── converters/             # Type converters
│   ├── errors/
│   │   └── failures.dart           # DatabaseFailure, ValidationFailure...
│   ├── services/
│   │   ├── backup_service.dart
│   │   └── logger_service.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   └── date_formatter.dart
│   ├── widgets/
│   │   ├── primary_button.dart
│   │   ├── app_card.dart
│   │   ├── confirm_dialog.dart
│   │   └── empty_view.dart
│   └── providers/
│       └── database_provider.dart
│
└── features/
    ├── dashboard/
    ├── transactions/               # Thu chi
    ├── sales/                      # Bán hàng
    ├── customers/                  # Khách hàng
    ├── suppliers/                  # Người bán
    ├── products/                   # Sản phẩm
    ├── inventory/                  # Kho
    ├── debts/                      # Công nợ
    ├── backup/                     # Sao lưu
    └── settings/                   # Cài đặt
```

Mỗi feature có cấu trúc:
```
feature/
├── domain/
│   ├── entities/
│   └── repositories/              # Abstract interface
├── application/
│   └── use_cases/
├── infrastructure/
│   ├── repositories/              # Implementation
│   ├── dto/
│   └── mappers/
└── presentation/
    ├── screens/
    └── widgets/
```

---

## Giai đoạn thực hiện

---

### 🏗️ Giai đoạn 1 — Nền tảng & Database (Ưu tiên cao nhất)

**Mục tiêu**: Thiết lập toàn bộ cơ sở hạ tầng, database, navigation

#### 1.1 Cấu hình dự án
- [x] Cập nhật `pubspec.yaml`: tên package, thêm tất cả dependencies
- [x] Tạo cấu trúc thư mục `lib/`

#### 1.2 Database Layer (Drift)
- [x] Tạo 15 table definitions theo thiết kế `04_Data_Dictionary_and_Database_Design.md`:
  - `customers_table.dart`
  - `suppliers_table.dart`
  - `product_categories_table.dart`
  - `units_table.dart`
  - `products_table.dart`
  - `sale_documents_table.dart`
  - `sale_items_table.dart`
  - `inventory_entries_table.dart`
  - `transactions_table.dart`
  - `customer_balances_table.dart`
  - `debt_transactions_table.dart`
  - `app_settings_table.dart`
  - `backup_logs_table.dart`
  - `app_logs_table.dart`
  - `database_info_table.dart`
- [x] Tạo `app_database.dart` (khai báo tất cả bảng)
- [x] Tạo DAOs cho từng bảng (CustomerDao, SaleDao, InventoryDao...)
- [x] Cấu hình Migration v1
- [x] Tạo Seed Data (danh mục mặc định, đơn vị kg, sản phẩm Chứng nước)
- [x] Chạy `build_runner` để generate code

#### 1.3 App Theme & Design System
- [x] `AppColors` — màu xanh cho Thu, đỏ cho Chi, warning cam
- [x] `AppTypography` — font Roboto, size tối thiểu 16sp
- [x] `AppSpacing`, `AppRadius`, `AppDurations`
- [x] `AppTheme` — Material 3

#### 1.4 Navigation
- [x] Cấu hình GoRouter: 5 tab (Trang chủ, Thu chi, Bán hàng, Công nợ, Khác)
- [x] Bottom Navigation Bar

#### 1.5 Core Widgets
- [x] `PrimaryButton`, `AppCard`, `ConfirmDialog`, `EmptyView`, `LoadingView`
- [x] `CurrencyFormatter` (định dạng `2.350.000 đ`)
- [x] `DateFormatter` (định dạng `dd/MM/yyyy`, `HH:mm`)

**Output**: Ứng dụng chạy được, bottom nav hoạt động, database khởi tạo thành công với seed data.

---

### 📊 Giai đoạn 2 — Tính năng cốt lõi (Nghiệp vụ chính)

**Mục tiêu**: Hoàn thiện các màn hình và nghiệp vụ quan trọng nhất

#### 2.1 Dashboard (SCR-001)
- [x] Domain: `DashboardSummary` entity
- [x] Repository: tổng hợp tiền hiện có, thu/chi hôm nay, tổng nợ, tồn kho
- [x] Provider: `dashboardProvider`
- [x] UI: 5 card (tiền hiện có, thu hôm nay, chi hôm nay, khách còn nợ, tồn kho)
- [x] 3 nút thao tác nhanh: Bán hàng, Thu tiền, Thêm khoản chi

#### 2.2 Thu Chi (SCR-002, SCR-003, SCR-004)
- [x] Domain: `Transaction` entity, `TransactionRepository` interface
- [x] Use Cases: `RecordIncomeUseCase`, `RecordExpenseUseCase`
- [x] Repository Implementation: `TransactionRepositoryImpl`
- [x] UI danh sách: search, filter (hôm nay/tuần/tháng/khoảng ngày), card xanh/đỏ
- [x] UI thêm khoản thu: dropdown loại thu, số tiền, ngày, nội dung
- [x] UI thêm khoản chi: dropdown loại chi, số tiền, ngày, nội dung
- [x] Validation: số tiền > 0, bắt buộc chọn loại

#### 2.3 Khách hàng (SCR-006, SCR-007)
- [x] Domain: `Customer` entity, `CustomerRepository` interface
- [x] Use Cases: `CreateCustomerUseCase`, `UpdateCustomerUseCase`, `DeactivateCustomerUseCase`
- [x] Repository: CRUD + soft delete
- [x] UI danh sách: tên, SĐT, số nợ; tìm kiếm; thêm mới
- [x] UI chi tiết: info khách + lịch sử mua + lịch sử thanh toán + nút Thu tiền
- [x] Xóa mềm ẩn khách khỏi danh sách; chỉnh sửa tải đúng bản ghi theo ID

#### 2.4 Bán hàng (SCR-005)
- [x] Domain: `Sale`, `SaleItem` entities
- [x] Use Case: `CreateSaleUseCase` (atomic database transaction)
  - Tạo `sale_documents`
  - Tạo `sale_items`
  - Ghi `inventory_entries` (sale)
  - Ghi `transactions` (nếu có tiền trả)
  - Ghi `debt_transactions` (nếu còn nợ)
  - Cập nhật `customer_balances`
  - Rollback nếu có lỗi
- [x] Kiểm tra tồn kho trước khi lưu (BR-802)
- [x] UI: chọn khách, chọn SP, nhập SL + đơn giá (auto-fill), tổng tiền, tiền trả, còn nợ
- [x] Tạo và giữ ID khách hàng mới ngay khi xác nhận tên + SĐT trong màn hình bán hàng

#### 2.5 Công nợ (SCR-011)
- [x] Domain: `CustomerBalance`, `DebtTransaction` entities
- [x] Use Case: `CollectDebtUseCase` (tạo giao dịch Thu + cập nhật số dư)
- [x] UI danh sách: tên + số nợ + ngày gần nhất; filter (còn nợ / đã TT)
- [x] UI thu tiền: chọn khách, nhập số tiền (không vượt số nợ - BR-503)
- [x] Chi tiết từng thẻ công nợ hiển thị số còn nợ sau khi phân bổ thu nợ

**Output**: Có thể dùng để ghi nhận bán hàng, thu chi, xem công nợ hằng ngày.

---

### 📦 Giai đoạn 3 — Tính năng bổ sung (Hoàn thiện)

**Mục tiêu**: Hoàn thiện tất cả màn hình còn lại

#### 3.1 Người bán / Nhà cung cấp
- [x] Màn hình danh sách nhà cung cấp
- [x] CRUD nhà cung cấp (BR-201 → BR-203)

#### 3.2 Sản phẩm (SCR-008, SCR-009)
- [x] Danh mục sản phẩm, đơn vị tính
- [x] CRUD sản phẩm (tuân thủ BR-301 → BR-304)
- [x] Nhập tồn kho ban đầu khi tạo sản phẩm (ghi qua Inventory Ledger)
- [x] Chi tiết: lịch sử nhập/bán, tồn kho hiện tại

#### 3.3 Kho hàng (SCR-010)
- [x] Tồn kho tính từ `inventory_entries` (Ledger Pattern)
- [x] Nhập kho: từ nhà cung cấp (`purchase`) và thu hoạch (`harvest`)
- [x] Điều chỉnh kho (`adjustment`)
- [x] Lịch sử biến động kho

#### 3.4 Cài đặt (SCR-013)
- [x] Cỡ chữ (font scale)
- [x] Sao lưu tự động (toggle)
- [x] Khoảng thời gian sao lưu
- [x] Thông tin ứng dụng, phiên bản Database
- [x] Thông tin về ứng dụng

#### 3.5 Backup & Restore — Local (SCR-012)
- [x] Tạo file backup: copy `.sqlite` → nén `.zip` → checksum SHA-256
- [x] Metadata: version, thời gian, số bản ghi
- [x] Restore: kiểm tra checksum → backup hiện tại → restore
- [x] Lưu log backup vào `backup_logs`
- [x] UI: danh sách backup local, nút Sao lưu ngay, Khôi phục
- [x] Chính sách giữ 10 bản local

**Output**: Ứng dụng hoàn chỉnh, đủ để sử dụng hằng ngày, có backup local.

---

### ☁️ Giai đoạn 4 — Nâng cao (Cloud & Bảo mật)

**Mục tiêu**: Tính năng nâng cao, an toàn dữ liệu cao hơn

#### 4.1 Google Drive Backup
- [x] Google Sign In
- [x] Upload backup lên Google Drive
- [x] Download backup từ Google Drive để restore
- [x] Hàng chờ upload khi không có mạng
- [x] Chính sách giữ 30 bản trên Drive

#### 4.2 Database Encryption (SQLCipher)
- [x] Tích hợp `sqlcipher_flutter_libs`
- [x] Lưu key trong `flutter_secure_storage`
- [x] Encrypt `.sqlite` file

#### 4.3 Sao lưu tự động
- [x] Background backup khi thoát app
- [x] Backup sau N giao dịch (cài đặt được)
- [x] Background task (WorkManager / Isolate)

#### 4.4 Báo cáo nâng cao
- [x] Thống kê theo tháng (tổng thu, tổng chi, lãi/lỗ)
- [x] Biểu đồ đơn giản
- [x] Báo cáo ngày/tháng tự cập nhật theo sổ thu chi và múi giờ địa phương
- [x] Giao diện báo cáo không tràn khi tăng cỡ chữ

**Output**: Ứng dụng production-ready, dữ liệu an toàn tối đa.

---

## Database Schema tóm tắt (15 bảng)

### Bảng nghiệp vụ (11 bảng)

| Bảng | Mô tả |
|------|-------|
| `customers` | Khách hàng (soft delete, is_active) |
| `suppliers` | Nhà cung cấp (soft delete) |
| `product_categories` | Danh mục sản phẩm |
| `units` | Đơn vị tính (kg, bao, con...) |
| `products` | Sản phẩm (seed: Chứng nước/kg) |
| `sale_documents` | Phiếu bán hàng |
| `sale_items` | Chi tiết phiếu bán |
| `inventory_entries` | Sổ cái kho (Ledger - chỉ INSERT) |
| `transactions` | Sổ cái thu chi (Ledger - chỉ INSERT) |
| `customer_balances` | Số dư công nợ tổng hợp |
| `debt_transactions` | Lịch sử biến động công nợ |

### Bảng hệ thống (4 bảng)

| Bảng | Mô tả |
|------|-------|
| `app_settings` | Cấu hình ứng dụng (1 dòng) |
| `backup_logs` | Nhật ký sao lưu |
| `app_logs` | Nhật ký hệ thống |
| `database_info` | Phiên bản database |

---

## Màn hình cần xây dựng (13 màn hình)

| Mã | Tên | Giai đoạn |
|----|-----|-----------|
| SCR-001 | Trang chủ (Dashboard) | 2 |
| SCR-002 | Danh sách thu chi | 2 |
| SCR-003 | Thêm khoản thu | 2 |
| SCR-004 | Thêm khoản chi | 2 |
| SCR-005 | Bán hàng | 2 |
| SCR-006 | Danh sách khách hàng | 2 |
| SCR-007 | Chi tiết khách hàng | 2 |
| SCR-008 | Danh sách sản phẩm | 3 |
| SCR-009 | Chi tiết sản phẩm | 3 |
| SCR-010 | Kho hàng | 3 |
| SCR-011 | Công nợ | 2 |
| SCR-012 | Backup & Restore | 3 |
| SCR-013 | Cài đặt | 3 |

---

## Quy tắc Business phải đảm bảo

- **BR-404**: Bán hàng chạy trong 1 Database Transaction, rollback khi lỗi
- **BR-502**: Khách có thể trả nhiều lần
- **BR-503**: Không thu vượt số nợ
- **BR-802**: Không cho bán khi tồn kho không đủ
- **BR-001**: Không xóa lịch sử (chỉ soft delete)
- **DB003**: Ledger pattern — inventory_entries, transactions, debt_transactions chỉ INSERT

---

## Kế hoạch xác minh

### Sau Giai đoạn 1
- Chạy `flutter run` thành công
- Database khởi tạo với seed data
- Bottom navigation hoạt động

### Sau Giai đoạn 2
- Ghi nhận bán hàng → kiểm tra tồn kho giảm, công nợ cập nhật
- Ghi thu/chi → Dashboard cập nhật
- Thu nợ → Số nợ khách giảm, giao dịch Thu được tạo

### Sau Giai đoạn 3
- Backup local tạo thành công, checksum hợp lệ
- Restore từ backup hoạt động đúng

### Sau Giai đoạn 4
- Upload Google Drive thành công
- Sao lưu tự động khi thoát app
