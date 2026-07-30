# 17_Drift_Database_Implementation.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả cách triển khai cơ sở dữ liệu bằng Drift.

Bao gồm:

- Tổ chức thư mục
- Định nghĩa bảng
- DAO
- Repository
- Migration
- Transaction
- Backup
- Performance

---

# 2. Kiến trúc Database

```
Flutter UI

↓

Use Case

↓

Repository

↓

DAO

↓

Drift Database

↓

SQLite
```

UI tuyệt đối không truy cập trực tiếp vào Database.

---

# 3. Cấu trúc thư mục

```text
lib/

core/

database/

├── app_database.dart

├── connection/

├── tables/

├── dao/

├── migrations/

├── converters/

├── seeds/

└── generated/
```

---

# 4. AppDatabase

AppDatabase là điểm truy cập duy nhất tới Database.

Chức năng:

- Khởi tạo SQLite.
- Khai báo bảng.
- Khai báo DAO.
- Quản lý phiên bản Database.
- Migration.

Ứng dụng chỉ có **một** AppDatabase.

---

# 5. Tables

Mỗi bảng nằm trong một file riêng.

Ví dụ:

```text
customers_table.dart

products_table.dart

sales_table.dart

transactions_table.dart

inventory_entries_table.dart
```

Không khai báo nhiều bảng trong cùng một file.

---

# 6. DAO (Data Access Object)

Mỗi bảng có một DAO riêng.

Ví dụ:

```text
CustomerDao

ProductDao

SaleDao

TransactionDao

InventoryDao
```

DAO chỉ thực hiện:

- Insert
- Update
- Query
- Delete mềm (nếu có)

Không chứa Business Logic.

---

# 7. Repository

Repository sử dụng DAO để thao tác dữ liệu.

Ví dụ:

```
CustomerRepository
```

↓

```
CustomerDao
```

↓

SQLite

Repository có thể kết hợp nhiều DAO để xử lý nghiệp vụ.

---

# 8. Migration

Mỗi lần thay đổi Database phải tăng version.

Ví dụ

Version 1

↓

Version 2

↓

Version 3

Migration phải:

- Không làm mất dữ liệu.
- Có thể nâng cấp từ phiên bản cũ.

Không hỗ trợ hạ phiên bản (Downgrade).

---

# 9. Transaction

Các nghiệp vụ nhiều bước phải chạy trong Transaction.

Ví dụ:

Bán hàng

↓

Tạo Sale

↓

Tạo Sale Item

↓

Trừ kho

↓

Tạo giao dịch thu tiền

↓

Cập nhật công nợ

↓

Commit

Nếu có lỗi:

Rollback toàn bộ.

---

# 10. Query

Nguyên tắc:

Không viết SQL trong UI.

Ví dụ:

Sai

```
SELECT * FROM customers
```

ở Widget.

Đúng

```
CustomerRepository.getAll()
```

---

# 11. Soft Delete

Các bảng hỗ trợ xóa mềm sẽ có:

```
deleted_at
```

Khi xóa:

Không xóa bản ghi.

Chỉ cập nhật thời gian xóa.

---

# 12. Enum

Các giá trị cố định sử dụng enum.

Ví dụ:

```dart
TransactionType

InventoryEntryType

PaymentMethod
```

Drift lưu dưới dạng INTEGER.

Không lưu chuỗi.

---

# 13. Date & Time

Tất cả thời gian lưu theo:

```
UTC
```

Khi hiển thị:

↓

Chuyển sang giờ địa phương.

Định dạng:

```
dd/MM/yyyy
```

```
HH:mm
```

---

# 14. UUID

Mỗi bảng có:

```
id
```

và

```
uuid
```

- `id`: khóa chính nội bộ (INTEGER).
- `uuid`: định danh toàn cục, phục vụ sao lưu, đồng bộ hoặc mở rộng sau này.

---

# 15. Index

Tạo Index cho các cột tìm kiếm thường xuyên.

Ví dụ:

```
customer_name

phone

product_name

created_at

business_date
```

Không tạo Index không cần thiết.

---

# 16. Seed Data

Dữ liệu khởi tạo gồm:

Danh mục thu chi

↓

Đơn vị

↓

Loại sản phẩm

↓

Cài đặt mặc định

Seed chỉ chạy khi tạo Database mới.

---

# 17. Backup

Backup sao chép toàn bộ Database.

Không Backup từng bảng riêng lẻ.

Sau khi Backup:

Kiểm tra checksum.

Nếu hợp lệ:

Lưu file.

Nếu không hợp lệ:

Hủy Backup.

---

# 18. Restore

Trước khi Restore:

- Kiểm tra phiên bản.
- Kiểm tra checksum.
- Sao lưu Database hiện tại.

Sau đó mới thay thế Database.

Khởi động lại ứng dụng sau khi hoàn tất.

---

# 19. Performance

Nguyên tắc:

- Chỉ tải dữ liệu cần thiết.
- Có phân trang khi danh sách lớn.
- Không truy vấn toàn bộ bảng nếu không cần.
- Ưu tiên JOIN thay vì nhiều truy vấn nhỏ khi phù hợp.

---

# 20. Logging

Các sự kiện cần ghi log:

- Migration.
- Backup.
- Restore.
- Lỗi Database.
- Transaction thất bại.

Không ghi dữ liệu cá nhân nhạy cảm.

---

# 21. Testing

Kiểm thử:

- Migration.
- Transaction.
- Backup.
- Restore.
- CRUD.

Sử dụng Database thử nghiệm cho Unit Test và Integration Test.

---

# 22. Quy tắc phát triển

- Một bảng → một file.
- Một DAO → một file.
- Một Repository → một file.
- Không viết SQL trong UI.
- Không viết Business Logic trong DAO.
- Không truy cập SQLite trực tiếp ngoài Drift.

---

# 23. Tổng kết

Drift là lớp truy cập dữ liệu duy nhất của ứng dụng.

Toàn bộ thao tác với cơ sở dữ liệu phải đi qua:

UI

↓

Use Case

↓

Repository

↓

DAO

↓

Drift

↓

SQLite

Kiến trúc này giúp hệ thống:

- Dễ bảo trì.
- Dễ kiểm thử.
- Dễ mở rộng.
- Đảm bảo tính toàn vẹn dữ liệu.
