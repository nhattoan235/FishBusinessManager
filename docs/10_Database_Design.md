# 10_Database_Design.md

> Version: 2.0
>
> Last Updated: 30/07/2026
>
> Status: Approved
>
> Database Engine: SQLite + Drift ORM
>
> Architecture: Offline First + Feature First + Clean Architecture + Ledger Pattern

---

# Chương 1. Mục tiêu thiết kế cơ sở dữ liệu

## 1.1 Mục tiêu

Cơ sở dữ liệu là thành phần quan trọng nhất của hệ thống.

Ứng dụng được xây dựng để phục vụ hoạt động kinh doanh thực tế hằng ngày, vì vậy dữ liệu phải được ưu tiên hơn mọi thành phần khác.

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

Hệ thống không cố gắng lưu quá nhiều dữ liệu đã được tính sẵn.

Thay vào đó:

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

Tồn kho được tính từ toàn bộ lịch sử.

Điều này giúp:

- Không mất lịch sử.
- Có thể kiểm tra lại mọi giao dịch.
- Dễ khôi phục dữ liệu.
- Hạn chế sai lệch.

---

## 1.3 Nguyên tắc thiết kế

### DB001 - Offline First

Toàn bộ dữ liệu được lưu trong SQLite.

Ứng dụng phải hoạt động bình thường khi:

- Không có Wi-Fi.
- Không có 4G.
- Không đăng nhập Google.

Internet chỉ phục vụ:

- Sao lưu.
- Khôi phục.
- Đồng bộ (nếu sau này bổ sung).

---

### DB002 - Single Source of Truth

SQLite là nguồn dữ liệu duy nhất.

Mọi màn hình đều đọc dữ liệu từ SQLite.

Không đọc trực tiếp từ:

- Google Drive
- File Backup
- Cache

---

### DB003 - Ledger Pattern

Các nghiệp vụ quan trọng đều lưu theo dạng sổ cái (Ledger).

Bao gồm:

- Biến động kho.
- Biến động công nợ.
- Thu.
- Chi.

Mỗi thay đổi tạo một bản ghi mới.

Không ghi đè lịch sử.

---

### DB004 - Không xóa dữ liệu nghiệp vụ

Không xóa vật lý:

- Giao dịch
- Bán hàng
- Công nợ
- Kho

Nếu người dùng chọn xóa, hệ thống sẽ sử dụng Soft Delete.

---

### DB005 - Mọi thay đổi đều có thời gian

Tất cả bảng nghiệp vụ đều có:

- created_at
- updated_at

Nếu hỗ trợ Soft Delete:

- deleted_at

---

### DB006 - Tiền luôn lưu bằng số nguyên

Ví dụ

Đúng

```
150000
```

Sai

```
150000.50
```

Đơn vị lưu trữ là **đồng (VND)**.

Định dạng hiển thị sẽ do giao diện xử lý.

---

### DB007 - Không lưu dữ liệu dư thừa

Không lưu những dữ liệu có thể tính được nếu việc tính toán không ảnh hưởng đến hiệu năng.

Ví dụ:

Không lưu:

```
Tổng thu tháng
```

Mà tính từ bảng giao dịch.

Riêng các dữ liệu cần truy cập liên tục (ví dụ công nợ hiện tại), có thể lưu bảng tổng hợp để tăng tốc độ hiển thị.

---

## 1.4 Yêu cầu mở rộng

Database phải sẵn sàng cho các nhu cầu sau mà không cần thiết kế lại:

- Thêm nhiều loại hàng hóa.
- Thêm nhiều kho.
- Thêm nhiều cửa hàng.
- Thêm nhiều người sử dụng.
- Đồng bộ nhiều thiết bị.
- Xuất Excel.
- Xuất PDF.
- In hóa đơn.
- Đồng bộ Cloud.

---

## 1.5 Tiêu chuẩn chất lượng

Thiết kế Database phải đảm bảo:

- Không mất dữ liệu.
- Không tạo dữ liệu trùng.
- Không sinh khóa ngoại lỗi.
- Dễ kiểm thử.
- Dễ nâng cấp phiên bản.

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

Google Drive không tham gia vào quá trình đọc và ghi dữ liệu hằng ngày.

Google Drive chỉ lưu bản sao lưu.

---

## 2.2 Các thành phần

### Flutter

Hiển thị giao diện.

Không truy cập Database.

---

### Riverpod

Quản lý trạng thái.

Điều phối dữ liệu giữa UI và Use Case.

---

### Use Case

Thực hiện nghiệp vụ.

Ví dụ:

- Bán hàng.
- Thu nợ.
- Ghi nhận chi.
- Sao lưu.

---

### Repository

Là lớp trung gian giữa nghiệp vụ và Database.

Repository chịu trách nhiệm:

- Đọc dữ liệu.
- Ghi dữ liệu.
- Cập nhật.
- Xóa mềm.
- Thực hiện Transaction.

---

### Drift ORM

Chuyển đổi giữa:

- Object Dart
- SQLite

Ưu điểm:

- Type-safe.
- Hỗ trợ Migration.
- Hỗ trợ Stream.
- Compile-time checking.

---

### SQLite

Lưu trữ dữ liệu vật lý.

Là nguồn dữ liệu duy nhất của ứng dụng.

---

## 2.3 Luồng ghi dữ liệu

Ví dụ bán hàng

```
Người dùng

↓

Nhấn Lưu

↓

SaleUseCase

↓

SaleRepository

↓

SQLite Transaction

↓

Tạo Sale Document

↓

Tạo Sale Item

↓

Ghi Inventory Ledger

↓

Ghi Transaction

↓

Cập nhật Debt Summary

↓

Ghi Debt Ledger

↓

Commit
```

Nếu bất kỳ bước nào thất bại:

```
Rollback
```

Không được phép lưu dữ liệu dở dang.

---

## 2.4 Luồng đọc dữ liệu

Ví dụ xem công nợ

```
Home Screen

↓

Debt Repository

↓

SQLite

↓

Debt Summary

↓

Hiển thị
```

Khi người dùng muốn xem lịch sử:

```
Debt Ledger

↓

Danh sách biến động
```

---

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

Có Internet?

↓

Có

↓

Upload Google Drive
```

Nếu Upload thất bại:

- Không xóa bản Local.
- Đánh dấu trạng thái thất bại.
- Thử lại theo lịch.

---

# Chương 3. Danh sách bảng và ERD

## 3.1 Danh sách bảng

| Bảng | Chức năng |
|------|-----------|
| customers | Thông tin người mua |
| suppliers | Thông tin nhà cung cấp |
| sale_documents | Thông tin một lần bán hàng |
| sale_items | Chi tiết hàng bán |
| inventory_entries | Sổ cái kho |
| transactions | Sổ cái thu chi |
| debts | Công nợ hiện tại |
| debt_transactions | Lịch sử biến động công nợ |
| backup_logs | Nhật ký sao lưu |
| app_logs | Nhật ký hệ thống |
| app_settings | Thiết lập ứng dụng |
| database_info | Thông tin phiên bản cơ sở dữ liệu |
| attachments | Tệp đính kèm (mở rộng trong tương lai) |

---

## 3.2 ERD tổng thể

```
customers
     │
     │ 1
     │
     ▼
sale_documents
     │
     │ 1
     ▼
sale_items
     │
     │
     ▼
inventory_entries

sale_documents
     │
     ├───────────────┐
     ▼               ▼
transactions   debt_transactions
                      │
                      ▼
                    debts

suppliers
     │
     ▼
inventory_entries

app_settings

backup_logs

database_info

app_logs

attachments
```

---

## 3.3 Quan hệ giữa các bảng

| Bảng cha | Quan hệ | Bảng con |
|-----------|----------|-----------|
| customers | 1 → N | sale_documents |
| sale_documents | 1 → N | sale_items |
| sale_documents | 1 → N | transactions |
| sale_documents | 1 → N | debt_transactions |
| customers | 1 → 1 | debts |
| suppliers | 1 → N | inventory_entries |

---

## 3.4 Vai trò của từng bảng

### customers

Lưu thông tin người mua.

Không lưu công nợ.

Không lưu giao dịch.

---

### sale_documents

Đại diện cho một lần bán hàng.

Lưu:

- Người mua
- Thời gian
- Ghi chú
- Tổng tiền

Không lưu chi tiết từng mặt hàng.

---

### sale_items

Lưu từng mặt hàng thuộc một lần bán.

Hiện tại có thể chỉ có một dòng cho "chứng nước", nhưng cấu trúc này cho phép mở rộng nhiều sản phẩm trong tương lai.

---

### inventory_entries

Là sổ cái kho.

Mọi biến động kho đều tạo một bản ghi mới.

Không cập nhật số lượng tồn trực tiếp.

---

### transactions

Là sổ cái tiền.

Bao gồm:

- Thu tiền bán hàng.
- Thu nợ.
- Thu khác.
- Chi mua hàng.
- Chi vận chuyển.
- Chi điện nước.
- Chi khác.

---

### debts

Lưu số công nợ hiện tại của từng khách hàng để truy vấn nhanh.

Đây là bảng tổng hợp (Summary Table).

---

### debt_transactions

Lưu lịch sử tăng hoặc giảm công nợ.

Cho phép xem lại toàn bộ quá trình phát sinh nợ và thu nợ của từng khách hàng.

---

# Chương 4. Thiết kế chi tiết các bảng nghiệp vụ

---

# 4.1 Bảng customers

## Mục đích

Lưu thông tin người mua.

Một người mua có thể:

- Mua nhiều lần.
- Có công nợ.
- Thanh toán nhiều lần.

Không lưu lịch sử giao dịch.

Không lưu số dư.

---

## Business Rule

- Không được trùng tên và số điện thoại nếu có nhập số điện thoại.
- Không xóa vật lý.
- Có thể khóa (is_active = false).
- Khách đã có giao dịch vẫn được phép sửa thông tin.
- Khách đã có giao dịch không được xóa.

---

## Schema

| Cột | Kiểu | Null | Mặc định | Mô tả |
|------|------|------|----------|-------|
| id | INTEGER | No | Auto | Primary Key |
| uuid | TEXT | No | UUID | Đồng bộ sau này |
| name | TEXT | No | | Tên khách |
| phone | TEXT | Yes | | SĐT |
| address | TEXT | Yes | | Địa chỉ |
| note | TEXT | Yes | | Ghi chú |
| is_active | INTEGER | No | 1 | Đang sử dụng |
| created_at | DATETIME | No | Now | Ngày tạo |
| updated_at | DATETIME | No | Now | Ngày sửa |
| deleted_at | DATETIME | Yes | | Soft Delete |

---

## Index

```
INDEX(name)

INDEX(phone)
```

---

## Ví dụ

| id | name |
|----|------|
|1|Nguyễn Văn A|
|2|Trần Văn B|

---

## Drift

Tên Table

```
Customers
```

Entity

```
Customer
```

Repository

```
CustomerRepository
```

---

# 4.2 Bảng suppliers

## Mục đích

Lưu nhà cung cấp.

Gia đình nhập thủ công.

Nhà cung cấp không sử dụng ứng dụng.

---

## Business Rule

- Không được xóa khi đã phát sinh nhập kho.
- Có thể khóa.
- Có thể sửa.

---

## Schema

| Cột | Kiểu |
|------|------|
| id | INTEGER |
| uuid | TEXT |
| name | TEXT |
| phone | TEXT |
| address | TEXT |
| note | TEXT |
| is_active | INTEGER |
| created_at | DATETIME |
| updated_at | DATETIME |
| deleted_at | DATETIME |

---

## Index

```
INDEX(name)
```

---

## Drift

```
Suppliers
```

---

# 4.3 Bảng sale_documents

## Mục đích

Đại diện cho một lần bán hàng.

Ví dụ

30/07/2026

↓

Khách Nguyễn Văn A

↓

Mua 20kg

↓

300.000đ

↓

Trả 200.000đ

↓

Nợ 100.000đ

Toàn bộ thông tin trên là một Sale Document.

---

## Business Rule

Một Sale Document

- Có ít nhất 1 Sale Item.
- Có thể phát sinh nhiều Transaction.
- Có thể phát sinh nhiều Debt Transaction.

Không được sửa khi đã Restore dữ liệu cũ.

---

## Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | PK |
| uuid | TEXT | UUID |
| customer_id | INTEGER | FK |
| total_amount | INTEGER | Tổng tiền |
| paid_amount | INTEGER | Đã trả |
| debt_amount | INTEGER | Còn nợ |
| note | TEXT | Ghi chú |
| sale_date | DATE | Ngày bán |
| sale_time | TIME | Giờ bán |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME | |

---

## Constraint

```
paid_amount <= total_amount

debt_amount >=0
```

---

## Index

```
customer_id

sale_date
```

---

## Drift

```
SaleDocuments
```

---

# 4.4 Bảng sale_items

## Mục đích

Lưu chi tiết từng mặt hàng.

Hiện tại

Có thể chỉ có

```
Chứng nước
```

Sau này

Có thể thêm

- Cá giống
- Thức ăn
- Thuốc

Không cần sửa Database.

---

## Business Rule

- Một Sale Document có nhiều Sale Item.
- Một Sale Item chỉ thuộc một Sale Document.

---

## Schema

| Cột | Kiểu |
|------|------|
| id | INTEGER |
| sale_document_id | INTEGER |
| product_name | TEXT |
| quantity | REAL |
| unit | TEXT |
| unit_price | INTEGER |
| total_price | INTEGER |
| note | TEXT |

---

## Constraint

```
quantity>0

unit_price>=0
```

---

## Index

```
sale_document_id
```

---

# 4.5 Bảng inventory_entries

## Mục đích

Đây là bảng quan trọng nhất của kho.

Ứng dụng sử dụng

Ledger Pattern.

Không lưu

```
Kho còn = 120kg
```

Mà lưu

```
+100kg

-20kg

+50kg

-5kg
```

---

## Business Rule

Mỗi biến động kho

↓

Một dòng.

Không Update.

Không Delete.

Chỉ thêm.

---

## Schema

| Cột | Kiểu |
|------|------|
| id | INTEGER |
| uuid | TEXT |
| entry_type | TEXT |
| supplier_id | INTEGER |
| sale_document_id | INTEGER |
| quantity | REAL |
| unit | TEXT |
| note | TEXT |
| created_at | DATETIME |

---

## entry_type

```
purchase

harvest

sale

adjustment
```

---

## quantity

Luôn dương.

Chiều tăng giảm dựa vào

entry_type.

Không dùng số âm.

---

## Ví dụ

|Type|Quantity|
|----|----|
|purchase|100|
|sale|20|
|harvest|80|

---

## Drift

```
InventoryEntries
```

---

# Chương 5. Thiết kế các bảng tài chính và hệ thống

---

# 5.1 transactions

## Mục đích

Là sổ cái tiền.

Mọi dòng tiền đều đi qua bảng này.

Bao gồm

- Thu
- Chi
- Thu nợ
- Thu bán hàng

---

## Business Rule

Không sửa số tiền sau khi đã lưu.

Nếu sai

↓

Tạo giao dịch điều chỉnh.

Không Update.

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|uuid|TEXT|
|transaction_type|TEXT|
|amount|INTEGER|
|description|TEXT|
|sale_document_id|INTEGER|
|transaction_date|DATE|
|transaction_time|TIME|
|created_at|DATETIME|

---

## transaction_type

```
income

expense

collect_debt

other
```

---

## Index

```
transaction_date

transaction_type
```

---

# 5.2 debts

## Mục đích

Bảng tổng hợp.

Hiển thị nhanh.

Không phải tính mỗi lần mở ứng dụng.

---

## Schema

|Cột|Kiểu|
|----|----|
|customer_id|INTEGER|
|current_debt|INTEGER|
|updated_at|DATETIME|

---

## Business Rule

Chỉ Repository được Update.

UI không được sửa.

---

# 5.3 debt_transactions

## Mục đích

Lưu lịch sử công nợ.

Ví dụ

```
+300000

Bán hàng

------

-100000

Thu nợ

------
```

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|customer_id|INTEGER|
|sale_document_id|INTEGER|
|change_type|TEXT|
|amount|INTEGER|
|note|TEXT|
|created_at|DATETIME|

---

## change_type

```
increase

decrease
```

---

## Drift

```
DebtTransactions
```

---

# 5.4 app_logs

## Mục đích

Nhật ký hệ thống.

Không hiển thị cho người dùng.

Chỉ dùng để kiểm tra lỗi.

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|module|TEXT|
|action|TEXT|
|record_id|INTEGER|
|description|TEXT|
|created_at|DATETIME|

---

Ví dụ

```
SALE

CREATE
```

---

# 5.5 backup_logs

## Mục đích

Theo dõi Backup.

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|file_name|TEXT|
|backup_type|TEXT|
|storage|TEXT|
|status|TEXT|
|checksum|TEXT|
|app_version|TEXT|
|db_version|INTEGER|
|created_at|DATETIME|

---

# 5.6 app_settings

## Mục đích

Lưu cấu hình.

Ứng dụng chỉ có

1 dòng dữ liệu.

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|font_scale|REAL|
|auto_backup|INTEGER|
|backup_interval|INTEGER|
|theme|TEXT|
|updated_at|DATETIME|

---

# 5.7 database_info

## Mục đích

Theo dõi Version Database.

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|schema_version|INTEGER|
|database_version|INTEGER|
|last_backup|DATETIME|

---

# 5.8 attachments

## Mục đích

Dự phòng mở rộng.

Hiện tại

Không dùng.

Sau này

Có thể lưu

- Hóa đơn
- Hình ảnh
- File PDF

---

## Schema

|Cột|Kiểu|
|----|----|
|id|INTEGER|
|module|TEXT|
|record_id|INTEGER|
|path|TEXT|
|created_at|DATETIME|

---

# 6. ERD (Entity Relationship Diagram)

## 6.1 Danh sách các bảng

Hệ thống bao gồm 15 bảng, được chia thành 3 nhóm:

### Bảng nghiệp vụ

| Bảng | Chức năng |
|------|-----------|
| customers | Quản lý khách hàng |
| suppliers | Quản lý nhà cung cấp |
| product_categories | Danh mục sản phẩm |
| units | Đơn vị tính |
| products | Quản lý sản phẩm |
| sale_documents | Phiếu bán hàng |
| sale_items | Chi tiết phiếu bán |
| inventory_entries | Sổ cái kho |
| transactions | Sổ cái thu chi |
| customer_balances | Số dư công nợ hiện tại |
| debt_transactions | Lịch sử công nợ |

### Bảng hệ thống

| Bảng | Chức năng |
|------|-----------|
| app_settings | Cấu hình ứng dụng |
| backup_logs | Nhật ký sao lưu |
| app_logs | Nhật ký hệ thống |
| database_info | Thông tin phiên bản Database |

---

## 6.2 ERD tổng quát

```text
customers
    │
    ├──────────────┐
    │              │
    ▼              ▼
sale_documents   customer_balances
    │
    ├──────────────┐
    │              │
    ▼              ▼
sale_items   debt_transactions
    │
    ▼
products
    │
    ├──────────────┐
    ▼              ▼
product_categories units

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

---

## 6.3 Quan hệ giữa các bảng

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

---

## 6.4 Luồng dữ liệu chính

### Bán hàng

Khách hàng

↓

Tạo Phiếu bán

↓

Thêm Chi tiết sản phẩm

↓

Ghi nhận Thu tiền

↓

Nếu chưa thanh toán hết

↓

Tạo Công nợ

↓

Giảm tồn kho

---

### Nhập hàng

Nhà cung cấp

↓

Nhập hàng

↓

Tăng tồn kho

↓

Nếu có thanh toán

↓

Ghi nhận Chi tiền

---

### Thu nợ

Chọn khách hàng

↓

Nhập số tiền khách trả

↓

Ghi lịch sử thu nợ

↓

Cập nhật số dư công nợ

↓

Ghi nhận Thu tiền

---

## 6.5 Nguyên tắc Ledger

Các bảng sau chỉ được **thêm mới (INSERT)**:

- inventory_entries
- transactions
- debt_transactions

Không được:

- UPDATE
- DELETE

Nếu nhập sai dữ liệu, hệ thống sẽ tạo bản ghi điều chỉnh thay vì sửa trực tiếp lịch sử.

---

# 7. Thiết kế bảng customers

## 7.1 Mục đích

Lưu thông tin khách hàng mua hàng.

Mỗi khách hàng có thể:

- Mua nhiều lần.
- Có công nợ.
- Thanh toán nhiều lần.

---

## 7.2 Schema

| Cột | Kiểu | Mô tả |
|------|------|-------|
| id | INTEGER | Primary Key |
| uuid | TEXT | Định danh duy nhất |
| name | TEXT | Tên khách hàng |
| phone | TEXT | Số điện thoại |
| address | TEXT | Địa chỉ |
| note | TEXT | Ghi chú |
| is_active | INTEGER | Đang sử dụng |
| created_at | DATETIME | Ngày tạo |
| updated_at | DATETIME | Ngày cập nhật |
| deleted_at | DATETIME | Xóa mềm |

---

## 7.3 Business Rule

- Bắt buộc nhập tên.
- Không được xóa khi đã phát sinh giao dịch.
- Có thể khóa khách hàng.
- Được phép cập nhật thông tin.

---

## 7.4 Index

```text
INDEX(name)

INDEX(phone)
```

---

## 7.5 Drift

Table

```
Customers
```

Repository

```
CustomerRepository
```

---

# 8. Thiết kế bảng suppliers

## 8.1 Mục đích

Quản lý thông tin nhà cung cấp.

Nhà cung cấp không trực tiếp sử dụng ứng dụng.

Toàn bộ dữ liệu được nhập thủ công bởi chủ cửa hàng.

---

## 8.2 Schema

| Cột | Kiểu |
|------|------|
| id | INTEGER |
| uuid | TEXT |
| name | TEXT |
| phone | TEXT |
| address | TEXT |
| note | TEXT |
| is_active | INTEGER |
| created_at | DATETIME |
| updated_at | DATETIME |
| deleted_at | DATETIME |

---

## 8.3 Business Rule

- Không được xóa nếu đã có lịch sử nhập hàng.
- Có thể khóa.
- Có thể chỉnh sửa thông tin.

---

## 8.4 Index

```text
INDEX(name)
```

---

## 8.5 Drift

Table

```
Suppliers
```

Repository

```
SupplierRepository
```

---

# 9. Thiết kế bảng product_categories

## 9.1 Mục đích

Phân loại sản phẩm để dễ quản lý và thống kê.

Ví dụ:

- Chứng nước
- Cá giống
- Thức ăn
- Thuốc
- Dụng cụ

---

## 9.2 Schema

| Cột | Kiểu |
|------|------|
| id | INTEGER |
| uuid | TEXT |
| name | TEXT |
| description | TEXT |
| created_at | DATETIME |
| updated_at | DATETIME |

---

## 9.3 Business Rule

- Không được trùng tên.
- Không được xóa nếu còn sản phẩm thuộc danh mục.

---

## 9.4 Index

```text
INDEX(name)
```

---

## 9.5 Drift

Table

```
ProductCategories
```

Repository

```
ProductCategoryRepository
```

---

# 10. Thiết kế bảng units

## 10.1 Mục đích

Quản lý đơn vị tính dùng chung cho toàn bộ hệ thống.

Ví dụ:

- kg
- bao
- con
- thùng
- gói

Việc quản lý bằng bảng riêng giúp dữ liệu thống nhất và dễ mở rộng.

---

## 10.2 Schema

| Cột | Kiểu |
|------|------|
| id | INTEGER |
| uuid | TEXT |
| name | TEXT |
| symbol | TEXT |
| created_at | DATETIME |

---

## 10.3 Business Rule

- Không được trùng tên.
- Không được xóa nếu đã có sản phẩm sử dụng.
- Một sản phẩm chỉ có một đơn vị mặc định.

---

## 10.4 Index

```text
INDEX(name)
```

---

## 10.5 Drift

Table

```
Units
```

Repository

```
UnitRepository
```

---

## 10.6 Ví dụ dữ liệu

| id | name | symbol |
|----|------|--------|
| 1 | Kilogram | kg |
| 2 | Bao | bao |
| 3 | Con | con |
| 4 | Thùng | thùng |
