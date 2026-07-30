# 04_Data_Dictionary_and_Database_Design.md

> Version: 3.0
>
> Last Updated: 30/07/2026
>
> Status: Approved
>
> Database Engine: SQLite + Drift ORM
>
> Architecture: Offline First + Feature First + Clean Architecture + Ledger Pattern
>
> Ghi chú: Tài liệu này gộp và thay thế `09_Data_Dictionary.md` và `10_Database_Design.md` của bộ tài liệu cũ. Mô hình dữ liệu chốt theo hướng **đa sản phẩm ngay từ phiên bản 1** (có `products`, `product_categories`, `units`).

---

# Chương 1. Mục tiêu và triết lý thiết kế

## 1.1 Mục tiêu

Cơ sở dữ liệu là thành phần quan trọng nhất của hệ thống.

Mục tiêu của Database:

- Lưu trữ dữ liệu ổn định trong nhiều năm.
- Không làm mất dữ liệu khi ứng dụng gặp lỗi.
- Hỗ trợ sao lưu và khôi phục nhanh.
- Dễ mở rộng khi có thêm nghiệp vụ mới.
- Dễ bảo trì.
- Tối ưu hiệu năng trên thiết bị Android.
- Hoạt động hoàn toàn khi không có Internet.

---

## 1.2 Triết lý thiết kế

Database được thiết kế theo nguyên tắc:

> Lưu lịch sử trước, tính toán sau.

Hệ thống không cố gắng lưu quá nhiều dữ liệu đã được tính sẵn. Thay vào đó:

- Lưu đầy đủ lịch sử phát sinh.
- Các số liệu tổng hợp sẽ được tính toán hoặc cập nhật từ lịch sử.

Ví dụ

Sai

```
Tồn kho = 150kg
```

Đúng

```
+200kg (Thu hoạch)
-30kg (Bán)
+50kg (Mua)
-20kg (Điều chỉnh)
```

Tồn kho được tính từ toàn bộ lịch sử (bảng `inventory_entries`).

---

## 1.3 Nguyên tắc thiết kế

### DB001 — Offline First

Toàn bộ dữ liệu được lưu trong SQLite. Ứng dụng phải hoạt động bình thường khi không có Internet. Internet chỉ phục vụ: Sao lưu, Khôi phục, Đồng bộ (nếu bổ sung sau này).

### DB002 — Single Source of Truth

SQLite là nguồn dữ liệu duy nhất. Mọi màn hình đều đọc dữ liệu từ SQLite. Không đọc trực tiếp từ Google Drive, File Backup, hoặc Cache.

### DB003 — Ledger Pattern

Các nghiệp vụ quan trọng đều lưu theo dạng sổ cái (Ledger): biến động kho, biến động công nợ, thu, chi. Mỗi thay đổi tạo một bản ghi mới. Không ghi đè lịch sử.

### DB004 — Không xóa dữ liệu nghiệp vụ

Không xóa vật lý: khách hàng, nhà cung cấp, sản phẩm, giao dịch, phiếu bán, công nợ, kho. Nếu người dùng chọn xóa, hệ thống sử dụng Soft Delete (`deleted_at`).

### DB005 — Mọi thay đổi đều có thời gian

Tất cả bảng nghiệp vụ đều có `created_at`, `updated_at`. Nếu hỗ trợ Soft Delete: thêm `deleted_at`.

### DB006 — Tiền luôn lưu bằng số nguyên

Đơn vị lưu trữ là **đồng (VND)**, kiểu `INTEGER`. Không lưu tiền dạng `REAL`. Định dạng hiển thị (dấu phân cách) do giao diện xử lý.

### DB007 — Không lưu dữ liệu dư thừa

Không lưu những dữ liệu có thể tính được nếu việc tính toán không ảnh hưởng hiệu năng (ví dụ: không lưu "Tổng thu tháng"). Riêng dữ liệu cần truy cập liên tục (ví dụ công nợ hiện tại) được lưu ở bảng tổng hợp (`customer_balances`) để tăng tốc hiển thị.

### DB008 — Một thông tin chỉ lưu tại một nơi

Tên sản phẩm chỉ lưu trong bảng `products`. `sale_items` chỉ lưu `product_id`, không lưu lại tên sản phẩm dạng text tự do.

---

## 1.4 Quy ước kiểu dữ liệu

| Kiểu | Ý nghĩa |
|------|----------|
| INTEGER | Số nguyên |
| TEXT | Chuỗi ký tự |
| REAL | Số thực (chỉ dùng cho số lượng, không dùng cho tiền) |
| BOOLEAN | Lưu dưới dạng INTEGER (0/1) trong SQLite |
| DATETIME | Ngày giờ, lưu UTC |
| DATE | Ngày |
| TIME | Giờ |

---

## 1.5 Yêu cầu mở rộng

Database phải sẵn sàng cho các nhu cầu sau mà không cần thiết kế lại:

- Thêm nhiều loại hàng hóa, danh mục, đơn vị tính.
- Thêm nhiều kho.
- Thêm nhiều cửa hàng.
- Thêm nhiều người sử dụng.
- Đồng bộ nhiều thiết bị.
- Xuất Excel / PDF.
- In hóa đơn.
- Đồng bộ Cloud.

---

## 1.6 Tiêu chuẩn chất lượng

Thiết kế Database phải đảm bảo: không mất dữ liệu, không tạo dữ liệu trùng, không sinh khóa ngoại lỗi, dễ kiểm thử, dễ nâng cấp phiên bản.

---

# Chương 2. Kiến trúc Database

## 2.1 Kiến trúc tổng thể

```
Flutter UI
    ↓
Riverpod
    ↓
Use Case
    ↓
Repository
    ↓
Local Data Source
    ↓
Drift ORM
    ↓
SQLite Database
    ↓
Database File
```

Google Drive không tham gia vào quá trình đọc/ghi dữ liệu hằng ngày. Google Drive chỉ lưu bản sao lưu.

## 2.2 Các thành phần

- **Flutter**: hiển thị giao diện, không truy cập Database.
- **Riverpod**: quản lý trạng thái, điều phối dữ liệu giữa UI và Use Case.
- **Use Case**: thực hiện nghiệp vụ (Bán hàng, Thu nợ, Ghi nhận chi, Sao lưu...).
- **Repository**: lớp trung gian giữa nghiệp vụ và Database — chịu trách nhiệm đọc/ghi/cập nhật/xóa mềm/transaction.
- **Drift ORM**: chuyển đổi giữa Object Dart và SQLite — type-safe, hỗ trợ Migration, hỗ trợ Stream.
- **SQLite**: lưu trữ dữ liệu vật lý, nguồn dữ liệu duy nhất.

## 2.3 Luồng ghi dữ liệu — Ví dụ bán hàng

```
Người dùng
    ↓
Nhấn Lưu
    ↓
CreateSaleUseCase
    ↓
SaleRepository
    ↓
SQLite Transaction
    ↓
Tạo sale_documents
    ↓
Tạo sale_items (theo product_id)
    ↓
Ghi inventory_entries (entry_type = sale)
    ↓
Ghi transactions (nếu khách trả tiền)
    ↓
Ghi debt_transactions (nếu còn nợ)
    ↓
Cập nhật customer_balances
    ↓
Commit
```

Nếu bất kỳ bước nào thất bại → **Rollback toàn bộ**. Không được phép lưu dữ liệu dở dang.

## 2.4 Luồng đọc dữ liệu — Ví dụ xem công nợ

```
Home Screen
    ↓
CustomerBalanceRepository
    ↓
SQLite (bảng customer_balances)
    ↓
Hiển thị
```

Khi người dùng muốn xem lịch sử chi tiết → đọc từ `debt_transactions`.

## 2.5 Kiến trúc Backup

```
SQLite
    ↓
Đóng Database
    ↓
Tạo Snapshot
    ↓
Nén
    ↓
Mã hóa
    ↓
Lưu Local Backup
    ↓
Có Internet? → Có → Upload Google Drive
             → Không → Đưa vào hàng chờ
```

Nếu Upload thất bại: không xóa bản Local, đánh dấu trạng thái thất bại, thử lại theo lịch. Chi tiết đầy đủ về chính sách backup xem `10_Data_Protection.md`.

---

# Chương 3. Danh sách bảng và ERD

## 3.1 Danh sách bảng

Hệ thống gồm **15 bảng**, chia 2 nhóm:

### Bảng nghiệp vụ

| Bảng | Chức năng |
|------|-----------|
| customers | Quản lý khách hàng |
| suppliers | Quản lý nhà cung cấp |
| product_categories | Danh mục sản phẩm |
| units | Đơn vị tính |
| products | Danh mục sản phẩm bán/nhập |
| sale_documents | Phiếu bán hàng |
| sale_items | Chi tiết phiếu bán (theo từng sản phẩm) |
| inventory_entries | Sổ cái kho |
| transactions | Sổ cái thu chi |
| customer_balances | Số dư công nợ hiện tại (bảng tổng hợp) |
| debt_transactions | Lịch sử biến động công nợ |

### Bảng hệ thống

| Bảng | Chức năng |
|------|-----------|
| app_settings | Cấu hình ứng dụng |
| backup_logs | Nhật ký sao lưu |
| app_logs | Nhật ký hệ thống |
| database_info | Thông tin phiên bản Database |

Bảng `attachments` được giữ như **bảng dự phòng mở rộng** (đính kèm hóa đơn/hình ảnh trong tương lai), không thuộc phạm vi bắt buộc của phiên bản 1 nhưng được tạo sẵn để tránh migration lớn sau này.

---

## 3.2 ERD tổng quát

```text
customers
    │
    ├──────────────┐
    │              │
    ▼              ▼
sale_documents   customer_balances
    │              │
    │              ▼
    │         debt_transactions
    ▼
sale_items
    │
    ▼
products ──────────────┐
    │                   │
    ▼                   ▼
product_categories    units

products
    │
    ▼
inventory_entries
    ▲
    │
suppliers

sale_documents
    │
    ▼
transactions
```

## 3.3 Quan hệ giữa các bảng

| Bảng cha | Quan hệ | Bảng con |
|-----------|----------|-----------|
| customers | 1 → N | sale_documents |
| customers | 1 → 1 | customer_balances |
| customers | 1 → N | debt_transactions |
| sale_documents | 1 → N | sale_items |
| sale_documents | 1 → N | transactions |
| sale_documents | 1 → N | debt_transactions |
| product_categories | 1 → N | products |
| units | 1 → N | products |
| products | 1 → N | sale_items |
| products | 1 → N | inventory_entries |
| suppliers | 1 → N | inventory_entries |

## 3.4 Nguyên tắc Ledger

Các bảng sau chỉ được **thêm mới (INSERT)**, không được `UPDATE`/`DELETE`:

- `inventory_entries`
- `transactions`
- `debt_transactions`

Nếu nhập sai dữ liệu, hệ thống tạo bản ghi điều chỉnh thay vì sửa trực tiếp lịch sử.

---

# Chương 4. Thiết kế chi tiết các bảng nghiệp vụ

## 4.1 Bảng customers

### Mục đích

Lưu thông tin khách hàng mua hàng. Một khách hàng có thể mua nhiều lần, có công nợ, thanh toán nhiều lần. Không lưu lịch sử giao dịch, không lưu số dư trực tiếp trong bảng này.

### Business Rule

- Bắt buộc nhập tên. Số điện thoại và địa chỉ không bắt buộc.
- Không được trùng tên + số điện thoại nếu có nhập số điện thoại.
- Không xóa vật lý khi đã phát sinh giao dịch. Chỉ được khóa (`is_active = false`).
- Khách đã có giao dịch vẫn được phép sửa thông tin.

### Schema

| Cột | Kiểu | Null | Mặc định | Mô tả |
|------|------|------|----------|-------|
| id | INTEGER | No | Auto | Primary Key |
| uuid | TEXT | No | UUID | Định danh toàn cục (đồng bộ sau này) |
| name | TEXT | No | | Tên khách hàng |
| phone | TEXT | Yes | | Số điện thoại |
| address | TEXT | Yes | | Địa chỉ |
| note | TEXT | Yes | | Ghi chú |
| is_active | INTEGER | No | 1 | Đang sử dụng |
| created_at | DATETIME | No | Now | Ngày tạo |
| updated_at | DATETIME | No | Now | Ngày sửa |
| deleted_at | DATETIME | Yes | | Soft Delete |

Index: `INDEX(name)`, `INDEX(phone)`

Drift: Table `Customers` — Repository `CustomerRepository`

---

## 4.2 Bảng suppliers

### Mục đích

Lưu nhà cung cấp. Nhà cung cấp **không** sử dụng ứng dụng — toàn bộ dữ liệu do chủ cửa hàng nhập thủ công.

### Business Rule

- Không được xóa khi đã phát sinh nhập kho. Chỉ được khóa.
- Có thể chỉnh sửa thông tin bất cứ lúc nào.

### Schema

| Cột | Kiểu | Null | Mặc định | Mô tả |
|------|------|------|----------|-------|
| id | INTEGER | No | Auto | Primary Key |
| uuid | TEXT | No | UUID | Định danh toàn cục |
| name | TEXT | No | | Tên nhà cung cấp |
| phone | TEXT | Yes | | Số điện thoại |
| address | TEXT | Yes | | Địa chỉ |
| note | TEXT | Yes | | Ghi chú |
| is_active | INTEGER | No | 1 | Đang sử dụng |
| created_at | DATETIME | No | Now | |
| updated_at | DATETIME | No | Now | |
| deleted_at | DATETIME | Yes | | Soft Delete |

Index: `INDEX(name)`

Drift: Table `Suppliers` — Repository `SupplierRepository`

---

## 4.3 Bảng product_categories

### Mục đích

Phân loại sản phẩm để dễ quản lý và thống kê. Ví dụ: Chứng nước, Cá giống, Thức ăn, Thuốc, Dụng cụ.

### Business Rule

- Không được trùng tên.
- Không được xóa nếu còn sản phẩm thuộc danh mục — chỉ được khóa/ẩn.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| uuid | TEXT | Định danh toàn cục |
| name | TEXT | Tên danh mục |
| description | TEXT | Mô tả |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Index: `INDEX(name)`

Drift: Table `ProductCategories` — Repository `ProductCategoryRepository`

---

## 4.4 Bảng units

### Mục đích

Quản lý đơn vị tính dùng chung cho toàn hệ thống. Ví dụ: kg, bao, con, thùng, gói.

### Business Rule

- Không được trùng tên.
- Không được xóa nếu đã có sản phẩm sử dụng.
- Một sản phẩm chỉ có một đơn vị mặc định.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| uuid | TEXT | |
| name | TEXT | Tên đơn vị |
| symbol | TEXT | Ký hiệu hiển thị |
| created_at | DATETIME | |

Index: `INDEX(name)`

Ví dụ dữ liệu khởi tạo (seed):

| id | name | symbol |
|----|------|--------|
| 1 | Kilogram | kg |
| 2 | Bao | bao |
| 3 | Con | con |
| 4 | Thùng | thùng |

Drift: Table `Units` — Repository `UnitRepository`

---

## 4.5 Bảng products

> **Ghi chú:** Bảng này bị thiếu trong bản thiết kế trước đó (`10_Database_Design.md` dừng lại ở bảng `units` mà chưa định nghĩa `products`). Thiết kế dưới đây được bổ sung để nhất quán với `product_categories`, `units`, `sale_items`, `inventory_entries` và với `12_Use_Cases.md` / `11_Business_Rules.md` (UC-021, BR-301, BR-302, BR-303, BR-304).

### Mục đích

Danh mục sản phẩm hệ thống bán hoặc nhập kho. Phiên bản đầu tiên có thể chỉ có 1 sản phẩm mặc định (Chứng nước) được seed sẵn, nhưng cấu trúc hỗ trợ nhiều sản phẩm ngay từ đầu.

### Business Rule

- Một sản phẩm thuộc đúng một danh mục (`category_id`).
- Một sản phẩm có một đơn vị tính mặc định (`unit_id`).
- Tên sản phẩm không được trùng trong cùng danh mục.
- Sản phẩm có thể ngừng kinh doanh (`is_active = false`): không cho chọn khi bán, không mất lịch sử.
- Không được xóa vật lý sản phẩm đã phát sinh giao dịch (`sale_items` hoặc `inventory_entries`).

### Schema

| Cột | Kiểu | Null | Mặc định | Mô tả |
|------|------|------|----------|-------|
| id | INTEGER | No | Auto | Primary Key |
| uuid | TEXT | No | UUID | Định danh toàn cục |
| category_id | INTEGER | No | | FK → product_categories.id |
| unit_id | INTEGER | No | | FK → units.id |
| name | TEXT | No | | Tên sản phẩm |
| default_price | INTEGER | Yes | | Giá bán mặc định (đồng) |
| note | TEXT | Yes | | Ghi chú |
| is_active | INTEGER | No | 1 | Đang kinh doanh |
| created_at | DATETIME | No | Now | |
| updated_at | DATETIME | No | Now | |
| deleted_at | DATETIME | Yes | | Soft Delete |

Index: `INDEX(name)`, `INDEX(category_id)`

Drift: Table `Products` — Repository `ProductRepository`

---

## 4.6 Bảng sale_documents

### Mục đích

Đại diện cho **một lần bán hàng**. Ví dụ: 30/07/2026 — khách Nguyễn Văn A — mua 20kg — 300.000đ — trả 200.000đ — nợ 100.000đ. Toàn bộ thông tin trên là một Sale Document.

### Business Rule

- Có ít nhất 1 `sale_item`.
- Có thể phát sinh nhiều `transactions` và nhiều `debt_transactions`.
- Không được sửa trực tiếp khi đã hoàn thành — nếu sai, tạo giao dịch điều chỉnh (BR-405).
- Toàn bộ việc tạo phiếu bán, trừ kho, ghi thu, ghi nợ phải nằm trong **một Database Transaction**. Nếu lỗi ở bất kỳ bước nào → rollback toàn bộ (BR-404).

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| uuid | TEXT | |
| customer_id | INTEGER | FK → customers.id |
| total_amount | INTEGER | Tổng tiền |
| paid_amount | INTEGER | Đã trả |
| debt_amount | INTEGER | Còn nợ |
| note | TEXT | Ghi chú |
| sale_date | DATE | Ngày bán |
| sale_time | TIME | Giờ bán |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME | |

Constraint: `paid_amount <= total_amount`, `debt_amount >= 0`

Index: `customer_id`, `sale_date`

Drift: Table `SaleDocuments` — Repository `SaleRepository`

---

## 4.7 Bảng sale_items

### Mục đích

Lưu chi tiết từng sản phẩm thuộc một lần bán.

### Business Rule

- Một `sale_document` có nhiều `sale_item`.
- Một `sale_item` chỉ thuộc một `sale_document` và tham chiếu đúng một `product`.
- Không cho phép số lượng bằng 0 hoặc đơn giá âm.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| sale_document_id | INTEGER | FK → sale_documents.id |
| product_id | INTEGER | FK → products.id |
| quantity | REAL | Số lượng |
| unit_price | INTEGER | Đơn giá tại thời điểm bán |
| total_price | INTEGER | Thành tiền |
| note | TEXT | Ghi chú |

Constraint: `quantity > 0`, `unit_price >= 0`

Index: `sale_document_id`, `product_id`

Drift: Table `SaleItems` — Repository `SaleRepository`

> **Thay đổi so với thiết kế cũ:** bảng này trước đây lưu `product_name` (TEXT tự do) và `unit` (TEXT) trực tiếp. Theo mô hình đa sản phẩm, hai cột này được thay bằng `product_id` (tham chiếu `products`, đã có sẵn `unit_id` và `category_id`) để tuân thủ DB008 — không lưu trùng dữ liệu.

---

## 4.8 Bảng inventory_entries

### Mục đích

Bảng quan trọng nhất của kho. Sử dụng **Ledger Pattern** — không lưu số tồn trực tiếp mà lưu từng biến động: `+100kg`, `-20kg`, `+50kg`, `-5kg`... Tồn kho hiện tại = tổng các biến động theo từng sản phẩm.

### Business Rule

- Mỗi biến động kho → một dòng mới. Không Update, không Delete, chỉ thêm.
- `quantity` luôn dương; chiều tăng/giảm suy ra từ `entry_type`.
- Không cho phép tồn kho tính toán ra số âm.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| uuid | TEXT | |
| product_id | INTEGER | FK → products.id |
| entry_type | TEXT | purchase / harvest / sale / adjustment |
| supplier_id | INTEGER | FK → suppliers.id (nullable, chỉ dùng khi entry_type = purchase) |
| sale_document_id | INTEGER | FK → sale_documents.id (nullable, chỉ dùng khi entry_type = sale) |
| quantity | REAL | Số lượng (luôn dương) |
| note | TEXT | Ghi chú |
| created_at | DATETIME | |

Ví dụ:

| entry_type | quantity |
|----|----|
| purchase | 100 |
| sale | 20 |
| harvest | 80 |

Index: `product_id`, `created_at`, `entry_type`

Drift: Table `InventoryEntries` — Repository `InventoryRepository`

> **Thay đổi so với thiết kế cũ:** bổ sung cột `product_id` (bị thiếu trong bản trước — không thể xác định biến động kho thuộc sản phẩm nào nếu có nhiều sản phẩm). Cột `unit` bị loại bỏ vì đơn vị đã xác định qua `products.unit_id`.

---

## 4.9 Bảng transactions

### Mục đích

Sổ cái tiền. Mọi dòng tiền đều đi qua bảng này: Thu, Chi, Thu nợ, Thu bán hàng.

### Business Rule

- Không sửa số tiền sau khi đã lưu. Nếu sai → tạo giao dịch điều chỉnh, không Update.
- Số tiền phải lớn hơn 0.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| uuid | TEXT | |
| transaction_type | TEXT | income / expense / collect_debt / other |
| amount | INTEGER | Số tiền |
| description | TEXT | Nội dung |
| sale_document_id | INTEGER | FK → sale_documents.id (nullable) |
| transaction_date | DATE | |
| transaction_time | TIME | |
| created_at | DATETIME | |

Index: `transaction_date`, `transaction_type`

Drift: Table `Transactions` — Repository `TransactionRepository`

---

## 4.10 Bảng customer_balances

### Mục đích

Bảng tổng hợp (Summary Table) — hiển thị nhanh công nợ hiện tại của từng khách hàng mà không cần tính lại từ lịch sử mỗi lần mở ứng dụng.

### Business Rule

- Chỉ Repository được phép Update bảng này. UI không được sửa trực tiếp.
- Khi cần đối soát, hệ thống có thể tính lại từ `debt_transactions`.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| customer_id | INTEGER | Primary Key, FK → customers.id |
| current_debt | INTEGER | Tổng nợ hiện tại |
| updated_at | DATETIME | Cập nhật gần nhất |

Drift: Table `CustomerBalances` — Repository `DebtRepository`

> **Đổi tên so với thiết kế cũ:** bảng này trước đây tên là `debts`. Đổi thành `customer_balances` để phân biệt rõ với `debt_transactions` (lịch sử) và tránh nhầm lẫn "một khách có nhiều khoản debt" — thực chất mỗi khách chỉ có **một số dư duy nhất**.

---

## 4.11 Bảng debt_transactions

### Mục đích

Lưu lịch sử tăng/giảm công nợ của từng khách hàng, cho phép xem lại toàn bộ quá trình phát sinh nợ và thu nợ.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| customer_id | INTEGER | FK → customers.id |
| sale_document_id | INTEGER | FK → sale_documents.id (nullable) |
| change_type | TEXT | increase / decrease |
| amount | INTEGER | Số tiền biến động |
| note | TEXT | |
| created_at | DATETIME | |

Ví dụ:

```
+300000   Bán hàng
-100000   Thu nợ
```

Index: `customer_id`, `created_at`

Drift: Table `DebtTransactions` — Repository `DebtRepository`

---

# Chương 5. Thiết kế các bảng hệ thống

## 5.1 app_settings

### Mục đích

Lưu cấu hình ứng dụng. Chỉ có **1 dòng dữ liệu** duy nhất.

### Schema

| Cột | Kiểu | Mặc định | Mô tả |
|------|------|----------|-------|
| id | INTEGER | 1 | Primary Key |
| font_scale | REAL | 1.0 | Cỡ chữ |
| theme | TEXT | light | Chế độ hiển thị |
| auto_backup | INTEGER | 1 | Tự động sao lưu |
| backup_interval | INTEGER | 24 | Giờ giữa các lần sao lưu tự động |
| keep_backup_days | INTEGER | 30 | Số ngày giữ bản sao lưu |
| use_google_drive | INTEGER | 1 | Bật sao lưu Google Drive |
| updated_at | DATETIME | Now | |

---

## 5.2 backup_logs

### Mục đích

Theo dõi lịch sử sao lưu.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| file_name | TEXT | Tên file |
| file_size | INTEGER | Kích thước |
| backup_type | TEXT | manual / scheduled |
| storage | TEXT | local / drive |
| status | TEXT | pending / completed / failed |
| checksum | TEXT | SHA-256 |
| app_version | TEXT | |
| db_version | INTEGER | |
| created_at | DATETIME | |

Chi tiết đầy đủ về quy trình sao lưu/khôi phục, checksum, metadata: xem `10_Data_Protection.md`.

---

## 5.3 app_logs

### Mục đích

Nhật ký hệ thống. Không hiển thị cho người dùng — chỉ dùng để kiểm tra lỗi.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| module | TEXT | Ví dụ: SALE, BACKUP, DEBT |
| action | TEXT | Ví dụ: CREATE, UPDATE, RESTORE |
| record_id | INTEGER | |
| description | TEXT | |
| created_at | DATETIME | |

Không ghi dữ liệu nhạy cảm (số điện thoại, địa chỉ chi tiết...) vào log.

---

## 5.4 database_info

### Mục đích

Theo dõi phiên bản Database phục vụ Migration.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| schema_version | INTEGER | |
| database_version | INTEGER | |
| last_backup | DATETIME | |

---

## 5.5 attachments (dự phòng mở rộng)

### Mục đích

Chưa sử dụng ở phiên bản 1. Chuẩn bị sẵn cho tương lai: lưu hóa đơn, hình ảnh, file PDF đính kèm.

### Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| module | TEXT | Bảng/nghiệp vụ liên quan |
| record_id | INTEGER | |
| path | TEXT | |
| created_at | DATETIME | |

---

# Chương 6. Khóa ngoại & Index tổng hợp

## 6.1 Bảng khóa ngoại

| Bảng | Khóa ngoại |
|------|------------|
| products | category_id → product_categories.id |
| products | unit_id → units.id |
| sale_documents | customer_id → customers.id |
| sale_items | sale_document_id → sale_documents.id |
| sale_items | product_id → products.id |
| inventory_entries | product_id → products.id |
| inventory_entries | supplier_id → suppliers.id (nullable) |
| inventory_entries | sale_document_id → sale_documents.id (nullable) |
| transactions | sale_document_id → sale_documents.id (nullable) |
| customer_balances | customer_id → customers.id |
| debt_transactions | customer_id → customers.id |
| debt_transactions | sale_document_id → sale_documents.id (nullable) |

## 6.2 Chỉ mục (Index)

| Bảng | Chỉ mục |
|------|----------|
| customers | name, phone |
| suppliers | name |
| product_categories | name |
| units | name |
| products | name, category_id |
| sale_documents | customer_id, sale_date |
| sale_items | sale_document_id, product_id |
| inventory_entries | product_id, created_at, entry_type |
| transactions | transaction_type, transaction_date |
| debt_transactions | customer_id, created_at |

Các chỉ mục sẽ được tối ưu thêm trong quá trình phát triển thực tế dựa trên truy vấn thường dùng.

---

# Chương 7. Quy tắc mở rộng

Kiến trúc dữ liệu phải hỗ trợ mở rộng mà **không cần thay đổi cấu trúc dữ liệu cốt lõi**:

- Nhiều kho.
- Nhiều cửa hàng.
- Nhiều người sử dụng.
- Đồng bộ nhiều thiết bị (đã có sẵn cột `uuid` ở các bảng chính).
- Xuất Excel / PDF.
- Báo cáo nâng cao.
- Đính kèm hóa đơn/hình ảnh (đã có sẵn bảng `attachments`).

---

# Chương 8. Kết luận

Data Dictionary & Database Design là tài liệu định nghĩa dữ liệu chuẩn duy nhất của toàn bộ hệ thống, thay thế hoàn toàn `09_Data_Dictionary.md` và `10_Database_Design.md` của bộ tài liệu trước.

Mọi thay đổi về bảng hoặc trường dữ liệu phải được cập nhật tại tài liệu này trước khi triển khai Database hoặc lập trình. Không tồn tại phiên bản thiết kế dữ liệu song song nào khác ngoài tài liệu này.
