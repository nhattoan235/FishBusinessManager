# 12_Use_Cases.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả toàn bộ Use Case của hệ thống.

Mỗi Use Case thể hiện:

- Người dùng thực hiện thao tác gì.
- Điều kiện để thực hiện.
- Các bước xử lý.
- Kết quả mong đợi.
- Trường hợp ngoại lệ.

Đây là tài liệu để lập trình viên triển khai Business Logic.

---

## 1.2 Quy ước

Mỗi Use Case có mã riêng.

Ví dụ:

UC-001

↓

Đăng nhập

UC-101

↓

Bán hàng

UC-301

↓

Backup dữ liệu

---

# 2. Danh sách Use Case

## Quản lý khách hàng

UC-001 Tạo khách hàng

UC-002 Chỉnh sửa khách hàng

UC-003 Khóa khách hàng

UC-004 Tìm kiếm khách hàng

---

## Quản lý nhà cung cấp

UC-011 Thêm nhà cung cấp

UC-012 Chỉnh sửa nhà cung cấp

UC-013 Tìm kiếm nhà cung cấp

---

## Quản lý sản phẩm

UC-021 Thêm sản phẩm

UC-022 Chỉnh sửa sản phẩm

UC-023 Ngừng kinh doanh sản phẩm

UC-024 Tìm kiếm sản phẩm

---

## Bán hàng

UC-101 Tạo phiếu bán

UC-102 Thu tiền

UC-103 Xem lịch sử bán hàng

UC-104 Xem chi tiết phiếu bán

---

## Thu chi

UC-201 Ghi nhận khoản thu

UC-202 Ghi nhận khoản chi

UC-203 Chỉnh sửa ghi chú giao dịch

UC-204 Xem lịch sử thu chi

---

## Công nợ

UC-301 Xem công nợ

UC-302 Thu nợ

UC-303 Xem lịch sử công nợ

---

## Kho

UC-401 Nhập kho

UC-402 Xuất kho

UC-403 Điều chỉnh kho

UC-404 Xem tồn kho

---

## Backup

UC-501 Backup thủ công

UC-502 Backup tự động

UC-503 Restore dữ liệu

---

## Cài đặt

UC-601 Thay đổi cài đặt

UC-602 Kiểm tra phiên bản Database

---

# 3. Mẫu Use Case

Mọi Use Case trong tài liệu đều sử dụng cùng một mẫu.

- Mã Use Case
- Mục tiêu
- Tác nhân
- Điều kiện
- Luồng chính
- Luồng ngoại lệ
- Dữ liệu vào
- Dữ liệu ra
- Business Rule liên quan

---

# 4. UC-001 — Tạo khách hàng

## Mục tiêu

Thêm khách hàng mới.

---

## Tác nhân

Chủ cửa hàng.

---

## Điều kiện

Ứng dụng đang hoạt động bình thường.

---

## Dữ liệu vào

- Tên khách hàng
- Số điện thoại (không bắt buộc)
- Địa chỉ (không bắt buộc)
- Ghi chú (không bắt buộc)

---

## Luồng chính

Bước 1

Người dùng chọn **Thêm khách hàng**.

↓

Bước 2

Nhập thông tin.

↓

Bước 3

Nhấn **Lưu**.

↓

Bước 4

Hệ thống kiểm tra dữ liệu.

↓

Bước 5

Lưu vào bảng `customers`.

↓

Bước 6

Hiển thị thông báo thành công.

---

## Ngoại lệ

Tên khách hàng để trống.

↓

Thông báo lỗi.

↓

Không lưu.

---

## Dữ liệu ra

Khách hàng mới được tạo.

---

## Business Rule

- BR-101
- BR-102

---

# 5. UC-021 — Thêm sản phẩm

## Mục tiêu

Thêm sản phẩm mới.

---

## Dữ liệu vào

- Danh mục
- Tên sản phẩm
- Đơn vị
- Giá mặc định
- Ghi chú

---

## Luồng chính

Người dùng chọn **Thêm sản phẩm**.

↓

Nhập thông tin.

↓

Kiểm tra dữ liệu.

↓

Lưu vào bảng `products`.

↓

Thông báo thành công.

---

## Ngoại lệ

Tên sản phẩm đã tồn tại trong cùng danh mục.

↓

Thông báo lỗi.

---

## Business Rule

- BR-301
- BR-302

---

# 6. UC-101 — Tạo phiếu bán

## Mục tiêu

Ghi nhận một lần bán hàng.

---

## Dữ liệu vào

- Khách hàng
- Danh sách sản phẩm
- Số lượng
- Đơn giá
- Số tiền khách trả ngay
- Ghi chú

---

## Luồng chính

Bước 1

Chọn khách hàng.

↓

Bước 2

Thêm sản phẩm.

↓

Bước 3

Nhập số lượng.

↓

Bước 4

Hệ thống tính thành tiền.

↓

Bước 5

Người dùng xác nhận.

↓

Bước 6

Bắt đầu Transaction.

↓

Bước 7

Tạo `sale_documents`.

↓

Bước 8

Tạo `sale_items`.

↓

Bước 9

Giảm tồn kho.

↓

Bước 10

Nếu khách trả tiền:

↓

Tạo `transactions`.

↓

Bước 11

Nếu còn nợ:

↓

Tạo `debt_transactions`.

↓

Cập nhật `customer_balances`.

↓

Bước 12

Commit Transaction.

↓

Bước 13

Thông báo thành công.

---

## Ngoại lệ

Không đủ tồn kho.

↓

Hủy Transaction.

↓

Hiển thị cảnh báo.

---

## Business Rule

- BR-401
- BR-402
- BR-701
- BR-801

---

# 7. UC-102 — Thu tiền khách

## Mục tiêu

Ghi nhận khách thanh toán công nợ.

---

## Dữ liệu vào

- Khách hàng
- Số tiền
- Ghi chú

---

## Luồng chính

Chọn khách hàng.

↓

Nhập số tiền.

↓

Kiểm tra công nợ.

↓

Tạo Transaction.

↓

Tạo Debt Transaction.

↓

Cập nhật Customer Balance.

↓

Hoàn thành.

---

## Ngoại lệ

Số tiền lớn hơn công nợ.

↓

Thông báo lỗi.

---

## Business Rule

- BR-501
- BR-502
- BR-503

---

# 8. UC-201 — Ghi nhận khoản chi

## Dữ liệu vào

- Loại chi
- Số tiền
- Ngày
- Nội dung

---

## Luồng chính

Người dùng chọn **Thêm khoản chi**.

↓

Nhập thông tin.

↓

Lưu vào bảng `transactions`.

↓

Thông báo thành công.

---

## Business Rule

- BR-601
- BR-603

---

# 9. UC-501 — Backup dữ liệu

## Mục tiêu

Tạo bản sao lưu dữ liệu.

---

## Luồng chính

Người dùng chọn **Sao lưu dữ liệu**.

↓

Hệ thống kiểm tra Database.

↓

Đóng kết nối ghi.

↓

Sao chép Database.

↓

Kiểm tra toàn vẹn.

↓

Nén dữ liệu.

↓

Lưu vào thư mục Backup trên máy.

↓

Nếu đã đăng nhập Google Drive:

↓

Tải lên Drive.

↓

Ghi `backup_logs`.

↓

Thông báo hoàn thành.

---

## Ngoại lệ

Không đủ dung lượng.

↓

Thông báo lỗi.

---

## Business Rule

- BR-001

---

# 10. UC-503 — Khôi phục dữ liệu

## Mục tiêu

Khôi phục dữ liệu từ bản sao lưu.

---

## Luồng chính

Người dùng chọn bản Backup.

↓

Hệ thống kiểm tra phiên bản.

↓

Kiểm tra tính toàn vẹn.

↓

Yêu cầu xác nhận.

↓

Sao lưu dữ liệu hiện tại.

↓

Khôi phục dữ liệu.

↓

Khởi động lại ứng dụng.

---

## Ngoại lệ

File không hợp lệ.

↓

Hủy Restore.

---

# 11. Tổng kết

Tài liệu này mô tả toàn bộ luồng xử lý nghiệp vụ của ứng dụng.

Trong giai đoạn lập trình:

- Mỗi Use Case sẽ tương ứng với một Use Case class trong tầng Domain.
- Repository chỉ thực hiện thao tác dữ liệu.
- Business Logic phải nằm trong Use Case.
- Mọi nghiệp vụ nhiều bước phải thực hiện trong một Database Transaction để đảm bảo tính toàn vẹn dữ liệu.
