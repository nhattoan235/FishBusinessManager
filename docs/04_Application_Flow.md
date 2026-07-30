# 04_Application_Flow.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Draft

---

# 1. Giới thiệu

Tài liệu này mô tả toàn bộ luồng hoạt động của ứng dụng.

Khác với Use Case chỉ mô tả từng chức năng riêng lẻ, Application Flow mô tả cách người dùng di chuyển giữa các màn hình và cách dữ liệu được cập nhật trong suốt quá trình sử dụng.

Đây là tài liệu nền tảng để:

- Thiết kế giao diện (UI)
- Thiết kế trải nghiệm người dùng (UX)
- Thiết kế Navigation
- Thiết kế State Management
- Thiết kế Database

---

# 2. Nguyên tắc thiết kế luồng

Ứng dụng được xây dựng theo các nguyên tắc sau.

## AF001

Mọi thao tác quan trọng đều hoàn thành trong tối đa 3 bước.

---

## AF002

Một màn hình chỉ tập trung vào một công việc.

Không đặt quá nhiều chức năng trên cùng một màn hình.

---

## AF003

Sau khi lưu dữ liệu phải quay về màn hình trước hoặc cập nhật ngay kết quả.

Không để người dùng phải tải lại.

---

## AF004

Không yêu cầu Internet để sử dụng.

---

## AF005

Người dùng luôn biết mình đang ở đâu trong ứng dụng.

---

# 3. Sơ đồ tổng quan

```text
Splash

↓

Trang chủ

├── Bán hàng
├── Thu / Chi
├── Kho
├── Người mua
├── Người bán
├── Báo cáo
├── Sao lưu
└── Cài đặt
```

---

# 4. Luồng khởi động

```text
Mở ứng dụng

↓

Hiển thị Splash

↓

Kiểm tra Database

↓

Đọc dữ liệu

↓

Hiển thị Trang chủ
```

Nếu Database lỗi

↓

Hiển thị hướng dẫn khôi phục.

---

# 5. Luồng Trang chủ

Trang chủ luôn là màn hình đầu tiên sau khi mở ứng dụng.

Hiển thị:

- Tiền hiện có
- Thu hôm nay
- Chi hôm nay
- Hàng còn
- Khách còn nợ
- 10 giao dịch gần nhất

Các nút chức năng chính:

- Bán hàng
- Thu / Chi
- Kho
- Báo cáo

Các chức năng ít dùng nằm trong menu:

- Người bán
- Sao lưu
- Khôi phục
- Cài đặt

---

# 6. Luồng Bán hàng

```text
Trang chủ

↓

Bán hàng

↓

Chọn người mua

↓

Nhập số lượng

↓

Nhập số tiền khách trả

↓

Lưu

↓

Cập nhật

• Kho
• Tiền
• Công nợ (nếu có)

↓

Quay về Trang chủ
```

---

# 7. Luồng Thu / Chi

```text
Trang chủ

↓

Thu / Chi

↓

Chọn

○ Thu

hoặc

○ Chi

↓

Nhập số tiền

↓

Nhập nội dung

↓

Lưu

↓

Cập nhật Tiền hiện có

↓

Quay về Trang chủ
```

---

# 8. Luồng Kho

```text
Trang chủ

↓

Kho

↓

Nhập hàng

↓

Chọn nguồn

○ Mua

○ Thu hoạch

↓

Nhập số lượng

↓

Lưu

↓

Kho tăng
```

---

# 9. Luồng Công nợ

```text
Trang chủ

↓

Danh sách khách còn nợ

↓

Chọn khách

↓

Thu nợ

↓

Nhập số tiền

↓

Lưu

↓

Giảm công nợ

↓

Sinh giao dịch Thu
```

---

# 10. Luồng Sao lưu

```text
Người dùng

↓

Nhấn

"Sao lưu ngay"

↓

Đóng gói dữ liệu

↓

Kiểm tra

↓

Lưu vào máy

↓

Có Internet ?

        │
   ┌────┴────┐
   │         │
 Có         Không
   │         │
   ▼         ▼
Upload    Đưa vào hàng chờ
```

---

# 11. Luồng Khôi phục

```text
Chọn bản sao lưu

↓

Kiểm tra file

↓

Tạo bản sao lưu hiện tại

↓

Khôi phục

↓

Kiểm tra dữ liệu

↓

Hoàn thành
```

Nếu lỗi

↓

Khôi phục dữ liệu cũ.

---

# 12. Luồng Báo cáo

```text
Trang chủ

↓

Báo cáo

↓

Chọn

Ngày

Tháng

Năm

↓

Hiển thị

• Tổng thu
• Tổng chi
• Tiền lời
• Công nợ
• Hàng còn
```

---

# 13. Luồng Cài đặt

Bao gồm:

- Kích thước chữ
- Sao lưu
- Khôi phục
- Giới thiệu ứng dụng
- Thông tin phiên bản

---

# 14. Luồng điều hướng

```text
Trang chủ

├── Bán hàng
├── Thu / Chi
├── Kho
├── Người mua
├── Người bán
├── Báo cáo
├── Sao lưu
└── Cài đặt
```

Mọi màn hình con đều có thể quay lại Trang chủ.

---

# 15. Quy tắc điều hướng

## AF101

Không có màn hình chết.

Người dùng luôn có nút quay lại.

---

## AF102

Sau khi lưu dữ liệu thành công phải hiển thị thông báo:

"Đã lưu thành công."

---

## AF103

Sau khi lưu thành công không yêu cầu người dùng tải lại dữ liệu.

---

## AF104

Nếu lưu thất bại phải giữ nguyên dữ liệu đã nhập để người dùng sửa.

---

## AF105

Không được mất dữ liệu khi chuyển màn hình.

---

# 16. Trạng thái màn hình

Mỗi màn hình đều phải hỗ trợ các trạng thái sau:

- Đang tải dữ liệu
- Không có dữ liệu
- Có dữ liệu
- Lỗi
- Đang lưu
- Thành công

Ví dụ:

Không có giao dịch

↓

Hiển thị:

"Chưa có giao dịch nào."

Thay vì hiển thị màn hình trắng.

---

# 17. Kết luận

Application Flow là tài liệu mô tả cách người dùng tương tác với toàn bộ hệ thống.

Tất cả các thiết kế UI, Navigation và State Management đều phải tuân thủ luồng được định nghĩa trong tài liệu này.

Nếu thay đổi luồng sử dụng, phải cập nhật tài liệu trước khi triển khai lập trình.
