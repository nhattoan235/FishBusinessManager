# 09_Data_Dictionary.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Approved

---

# 1. Mục tiêu

Tài liệu này định nghĩa toàn bộ dữ liệu của hệ thống trước khi thiết kế cơ sở dữ liệu.

Mỗi bảng đều mô tả:

- Mục đích
- Ý nghĩa nghiệp vụ
- Các trường dữ liệu
- Kiểu dữ liệu
- Bắt buộc hay không
- Giá trị mặc định
- Ghi chú

Đây là tài liệu tham chiếu chính cho việc thiết kế Database và lập trình.

---

# 2. Quy ước kiểu dữ liệu

| Kiểu | Ý nghĩa |
|------|----------|
| INTEGER | Số nguyên |
| TEXT | Chuỗi ký tự |
| REAL | Số thực |
| BOOLEAN | Đúng / Sai |
| DATETIME | Ngày giờ |
| DATE | Ngày |
| TIME | Giờ |

---

# 3. Bảng customers

## Mục đích

Lưu thông tin người mua.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| name | TEXT | Có | | Tên người mua |
| phone | TEXT | Không | | Số điện thoại |
| address | TEXT | Không | | Địa chỉ |
| note | TEXT | Không | | Ghi chú |
| is_active | BOOLEAN | Có | true | Đang sử dụng |
| created_at | DATETIME | Có | Now | Ngày tạo |
| updated_at | DATETIME | Có | Now | Ngày cập nhật |

---

# 4. Bảng suppliers

## Mục đích

Lưu thông tin nơi cung cấp chứng nước hoặc các nguồn cung khác.

Lưu ý:

Nhà cung cấp không sử dụng ứng dụng.

Toàn bộ thông tin được chủ cửa hàng nhập thủ công.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| name | TEXT | Có | | Tên nhà cung cấp |
| phone | TEXT | Không | | Số điện thoại |
| address | TEXT | Không | | Địa chỉ |
| note | TEXT | Không | | Ghi chú |
| is_active | BOOLEAN | Có | true | Đang sử dụng |
| created_at | DATETIME | Có | Now | Ngày tạo |
| updated_at | DATETIME | Có | Now | Ngày cập nhật |

---

# 5. Bảng inventory_entries

## Mục đích

Ghi nhận mọi biến động của kho.

Bao gồm:

- Nhập từ nhà cung cấp
- Thu hoạch
- Bán hàng
- Điều chỉnh tồn kho

Không lưu trực tiếp số lượng tồn.

Số lượng tồn được tính từ lịch sử biến động.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| entry_type | TEXT | Có | | purchase / harvest / sale / adjustment |
| supplier_id | INTEGER | Không | | Nhà cung cấp |
| quantity | REAL | Có | 0 | Số lượng |
| unit | TEXT | Có | kg | Đơn vị |
| note | TEXT | Không | | Ghi chú |
| created_at | DATETIME | Có | Now | Ngày tạo |

---

# 6. Bảng sales

## Mục đích

Lưu thông tin bán hàng.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| customer_id | INTEGER | Có | | Người mua |
| quantity | REAL | Có | | Số lượng |
| unit_price | INTEGER | Có | | Đơn giá |
| total_amount | INTEGER | Có | | Tổng tiền |
| paid_amount | INTEGER | Có | 0 | Đã trả |
| debt_amount | INTEGER | Có | 0 | Còn nợ |
| note | TEXT | Không | | Ghi chú |
| created_at | DATETIME | Có | Now | Ngày bán |

---

# 7. Bảng transactions

## Mục đích

Lưu tất cả giao dịch thu và chi.

Bao gồm:

- Thu tiền bán hàng
- Thu nợ
- Thu khác
- Chi mua hàng
- Chi xăng
- Chi điện
- Chi thức ăn
- Chi khác

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| type | TEXT | Có | | income / expense |
| amount | INTEGER | Có | | Số tiền |
| title | TEXT | Có | | Nội dung |
| description | TEXT | Không | | Chi tiết |
| transaction_date | DATE | Có | Today | Ngày |
| transaction_time | TIME | Có | Now | Giờ |
| sale_id | INTEGER | Không | | Liên kết đơn bán |
| created_at | DATETIME | Có | Now | Ngày tạo |

---

# 8. Bảng debts

## Mục đích

Theo dõi công nợ của khách.

Lưu ý:

Đây là bảng phục vụ tra cứu nhanh.

Lịch sử chi tiết vẫn nằm trong bảng sales.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| customer_id | INTEGER | Có | | Người mua |
| current_debt | INTEGER | Có | 0 | Tổng nợ hiện tại |
| updated_at | DATETIME | Có | Now | Cập nhật gần nhất |

---

# 9. Bảng backup_logs

## Mục đích

Theo dõi lịch sử sao lưu.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | Auto | Khóa chính |
| file_name | TEXT | Có | | Tên file |
| file_size | INTEGER | Có | | Kích thước |
| backup_type | TEXT | Có | manual / scheduled | Loại sao lưu |
| storage | TEXT | Có | local / drive | Nơi lưu |
| status | TEXT | Có | completed | Trạng thái |
| created_at | DATETIME | Có | Now | Thời gian |

---

# 10. Bảng app_settings

## Mục đích

Lưu các thiết lập của ứng dụng.

---

| Trường | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|-----------|--------|
| id | INTEGER | Có | 1 | Khóa chính |
| font_scale | REAL | Có | 1.0 | Cỡ chữ |
| auto_backup | BOOLEAN | Có | true | Tự động sao lưu |
| backup_interval | INTEGER | Có | 24 | Giờ |
| keep_backup_days | INTEGER | Có | 30 | Số ngày giữ bản sao lưu |
| use_google_drive | BOOLEAN | Có | true | Sao lưu Google Drive |
| updated_at | DATETIME | Có | Now | Ngày cập nhật |

---

# 11. Quy tắc dữ liệu

- Không xóa vật lý dữ liệu nghiệp vụ nếu không thật sự cần thiết.
- Mọi giao dịch đều có thời gian tạo.
- Mọi số tiền lưu dưới dạng số nguyên (đơn vị: đồng).
- Không lưu số tiền dưới dạng REAL.
- Ngày và giờ được lưu riêng (`transaction_date`, `transaction_time`) để thuận tiện cho việc lọc theo nhu cầu của người dùng, đồng thời vẫn có `created_at` phục vụ kiểm toán và đồng bộ.

---

# 12. Quy tắc khóa ngoại

| Bảng | Khóa ngoại |
|------|------------|
| sales | customer_id → customers.id |
| inventory_entries | supplier_id → suppliers.id |
| transactions | sale_id → sales.id |
| debts | customer_id → customers.id |

---

# 13. Chỉ mục (Index) dự kiến

| Bảng | Chỉ mục |
|------|----------|
| customers | name |
| suppliers | name |
| sales | customer_id, created_at |
| transactions | type, transaction_date, created_at |
| debts | customer_id |

Các chỉ mục sẽ được tối ưu thêm khi thiết kế Database.

---

# 14. Quy tắc mở rộng

Kiến trúc dữ liệu phải hỗ trợ mở rộng:

- Nhiều loại hàng.
- Nhiều kho.
- Nhiều cửa hàng.
- Đồng bộ nhiều thiết bị.
- Xuất Excel/PDF.
- Báo cáo nâng cao.

Không cần thay đổi cấu trúc dữ liệu cốt lõi.

---

# 15. Kết luận

Data Dictionary là tài liệu định nghĩa dữ liệu chuẩn của toàn bộ hệ thống.

Mọi thay đổi về bảng hoặc trường dữ liệu phải được cập nhật tại tài liệu này trước khi triển khai Database hoặc lập trình.
