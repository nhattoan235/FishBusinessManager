# 02_UseCase_Specification.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Draft

---

# 1. Giới thiệu

Tài liệu này mô tả chi tiết toàn bộ Use Case của hệ thống.

Mục tiêu:

- Thống nhất nghiệp vụ trước khi lập trình.
- Làm tài liệu cho Developer.
- Làm tài liệu kiểm thử.
- Làm cơ sở xây dựng Activity Diagram và Sequence Diagram.

---

# 2. Danh sách Use Case

| Mã | Tên Use Case | Độ ưu tiên |
|-----|--------------|------------|
| UC01 | Quản lý người mua | Cao |
| UC02 | Quản lý người bán | Trung bình |
| UC03 | Quản lý sản phẩm | Cao |
| UC04 | Quản lý kho | Cao |
| UC05 | Bán hàng | Rất cao |
| UC06 | Thu nợ | Rất cao |
| UC07 | Thu tiền | Rất cao |
| UC08 | Chi tiền | Rất cao |
| UC09 | Xem sổ tiền | Rất cao |
| UC10 | Báo cáo | Trung bình |
| UC11 | Sao lưu dữ liệu | Cao |
| UC12 | Khôi phục dữ liệu | Cao |
| UC13 | Cài đặt | Thấp |

---

# UC01 - Quản lý người mua

## Mục đích

Quản lý thông tin khách mua hàng.

## Actor

Chủ cửa hàng.

## Tiền điều kiện

Đã mở ứng dụng.

## Hậu điều kiện

Thông tin người mua được lưu.

## Luồng chính

1. Mở màn hình Người mua.
2. Chọn Thêm.
3. Nhập thông tin.
4. Lưu.

## Luồng thay thế

Nếu người mua đã tồn tại:

Hiển thị cảnh báo.

Cho phép tiếp tục hoặc hủy.

## Ngoại lệ

Không nhập tên.

↓

Không cho lưu.

---

# UC02 - Quản lý người bán

## Mục đích

Quản lý nơi cung cấp chứng nước.

## Lưu ý

Người bán KHÔNG sử dụng hệ thống.

Chủ cửa hàng nhập thủ công.

Các thao tác:

- Thêm
- Sửa
- Xóa
- Tìm kiếm

---

# UC03 - Quản lý sản phẩm

## Mục đích

Quản lý danh sách sản phẩm.

Phiên bản đầu:

- Chứng nước.

Các thao tác:

- Thêm
- Sửa
- Ngừng bán

Không cho xóa sản phẩm đã phát sinh giao dịch.

---

# UC04 - Quản lý kho

## Mục đích

Quản lý số lượng hàng.

### Luồng chính

1. Mở Kho.
2. Chọn Nhập hàng.
3. Chọn nguồn.

- Người bán
- Thu hoạch

4. Nhập số lượng.

5. Lưu.

Hệ thống cập nhật tồn kho.

---

# UC05 - Bán hàng

## Mức ưu tiên

Rất cao.

## Mục đích

Ghi nhận một lần bán hàng.

## Tiền điều kiện

- Có sản phẩm.
- Có đủ hàng.

## Hậu điều kiện

- Giảm tồn kho.
- Nếu khách trả tiền → tạo giao dịch Thu.
- Nếu khách còn thiếu → tạo Công nợ.

## Luồng chính

1. Chọn người mua.
2. Chọn sản phẩm.
3. Nhập số lượng.
4. Hệ thống tính tiền.
5. Nhập số tiền khách trả.
6. Lưu.

## Luồng thay thế

Khách trả thiếu.

↓

Sinh công nợ.

## Ngoại lệ

Không đủ hàng.

↓

Không cho lưu.

---

# UC06 - Thu nợ

## Mục đích

Thu tiền từ khách còn nợ.

## Luồng chính

1. Chọn khách.
2. Chọn khoản nợ.
3. Nhập số tiền.
4. Lưu.

Hệ thống:

- Giảm công nợ.
- Tạo giao dịch Thu.

## Ngoại lệ

Số tiền thu lớn hơn số nợ.

↓

Không cho lưu.

---

# UC07 - Thu tiền

## Mục đích

Ghi nhận khoản tiền vào.

## Luồng chính

1. Nhập số tiền.
2. Chọn ngày giờ.
3. Nhập nội dung.
4. Lưu.

Hệ thống:

- Cập nhật Tiền hiện có.
- Thêm vào lịch sử.

---

# UC08 - Chi tiền

## Mục đích

Ghi nhận khoản chi.

## Luồng chính

1. Nhập số tiền.
2. Chọn ngày giờ.
3. Nhập nội dung.
4. Lưu.

Hệ thống:

- Trừ Tiền hiện có.
- Thêm vào lịch sử.

---

# UC09 - Xem sổ tiền

## Mục đích

Theo dõi toàn bộ dòng tiền.

Hiển thị:

- Tiền hiện có.
- Thu hôm nay.
- Chi hôm nay.
- Danh sách giao dịch.

Cho phép lọc:

- Theo ngày.
- Theo tháng.
- Theo năm.
- Theo khoảng thời gian.
- Chỉ Thu.
- Chỉ Chi.

---

# UC10 - Báo cáo

Cho phép xem:

- Theo ngày.
- Theo tháng.
- Theo năm.

Bao gồm:

- Tổng thu.
- Tổng chi.
- Tiền lời.
- Công nợ.
- Hàng tồn.

---

# UC11 - Sao lưu dữ liệu

## Mục đích

Đảm bảo dữ liệu luôn được bảo vệ.

## Luồng hệ thống

Hệ thống tự động:

- Tạo bản sao lưu.
- Kiểm tra thành công.
- Lưu vào điện thoại.
- Nếu có Internet → tải lên Google Drive.

Người dùng có thể chọn:

"Sao lưu ngay"

nếu muốn.

---

# UC12 - Khôi phục dữ liệu

## Mục đích

Khôi phục dữ liệu từ bản sao lưu.

## Luồng chính

1. Chọn bản sao lưu.
2. Hệ thống kiểm tra file.
3. Tự tạo bản sao lưu hiện tại.
4. Khôi phục.
5. Kiểm tra dữ liệu.
6. Thông báo thành công.

Nếu lỗi:

Không thay đổi dữ liệu hiện tại.

---

# UC13 - Cài đặt

Bao gồm:

- Kích thước chữ.
- Chế độ sáng.
- Sao lưu.
- Thông tin ứng dụng.

---

# 3. Quan hệ giữa các Use Case

UC05 Bán hàng

include

- Kiểm tra tồn kho
- Giảm tồn kho
- Tạo giao dịch

extend

- Sinh công nợ

---

UC06 Thu nợ

include

- Cập nhật công nợ
- Tạo giao dịch Thu

---

UC12 Khôi phục

include

- Kiểm tra file
- Tạo bản sao lưu hiện tại

---

# 4. Use Case ưu tiên

## Bắt buộc trong Version 1

- UC01
- UC04
- UC05
- UC06
- UC07
- UC08
- UC09
- UC11
- UC12

Các Use Case còn lại có thể phát triển sau.

---

# 5. Kết luận

Use Case là cơ sở để:

- Thiết kế Activity Diagram.
- Thiết kế Sequence Diagram.
- Thiết kế Database.
- Viết Unit Test.
- Viết Integration Test.

Mọi thay đổi nghiệp vụ phải cập nhật Use Case trước khi triển khai lập trình.
