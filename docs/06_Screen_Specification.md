# 06_Screen_Specification.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả chi tiết từng màn hình của ứng dụng.

Mỗi màn hình bao gồm:

- Mục đích
- Thành phần giao diện
- Dữ liệu hiển thị
- Các nút chức năng
- Điều hướng
- Quy tắc hiển thị
- Quy tắc kiểm tra dữ liệu

Tài liệu này là cơ sở để triển khai giao diện Flutter.

---

# 2. Danh sách màn hình

| Mã | Tên màn hình |
|-----|--------------|
| SCR-001 | Trang chủ |
| SCR-002 | Danh sách thu chi |
| SCR-003 | Thêm khoản thu |
| SCR-004 | Thêm khoản chi |
| SCR-005 | Bán hàng |
| SCR-006 | Danh sách khách hàng |
| SCR-007 | Chi tiết khách hàng |
| SCR-008 | Danh sách sản phẩm |
| SCR-009 | Chi tiết sản phẩm |
| SCR-010 | Kho hàng |
| SCR-011 | Công nợ |
| SCR-012 | Backup & Restore |
| SCR-013 | Cài đặt |

---

# 3. SCR-001 — Trang chủ

## Mục đích

Là màn hình đầu tiên khi mở ứng dụng.

Hiển thị nhanh các thông tin quan trọng nhất.

---

## Wireframe

```

┌────────────────────────────┐

Xin chào!

Hôm nay: 30/07/2026

────────────────────────────

Tiền hiện có

15.200.000 đ

────────────────────────────

Hôm nay

🟢 Thu

+2.500.000

🔴 Chi

-800.000

────────────────────────────

Khách còn nợ

3.400.000 đ

────────────────────────────

Tồn kho

320 kg

────────────────────────────

[ Bán hàng ]

[ Thu tiền ]

[ Thêm khoản chi ]

────────────────────────────

Bottom Navigation

└────────────────────────────┘

```

---

## Thành phần

- AppBar
- Card tổng tiền
- Card thu hôm nay
- Card chi hôm nay
- Card công nợ
- Card tồn kho
- Nút thao tác nhanh
- Bottom Navigation

---

## Hành động

Nhấn

"Bán hàng"

↓

SCR-005

---

Nhấn

"Thu tiền"

↓

SCR-011

---

Nhấn

"Tồn kho"

↓

SCR-010

---

# 4. SCR-002 — Danh sách thu chi

## Mục đích

Hiển thị toàn bộ lịch sử thu và chi.

---

## Wireframe

```

┌────────────────────────────┐

🔍 Tìm kiếm

────────────────────────────

[Lọc]

Hôm nay

Tháng này

Khoảng ngày

────────────────────────────

🟢

+500.000

Bán chứng nước

09:30

30/07/2026

────────────────────────────

🔴

-300.000

Mua thức ăn

11:20

30/07/2026

────────────────────────────

Floating Button (+)

└────────────────────────────┘

```

---

## Thành phần

- Search Bar
- Bộ lọc
- Danh sách Card
- Floating Action Button

---

## Quy tắc hiển thị

Thu

↓

Màu xanh

↓

Dấu +

---

Chi

↓

Màu đỏ

↓

Dấu -

---

Sắp xếp

↓

Mới nhất lên trên.

---

## Hành động

Nhấn Card

↓

Xem chi tiết giao dịch.

---

Nhấn (+)

↓

Chọn

- Thêm khoản thu
- Thêm khoản chi

---

# 5. SCR-003 — Thêm khoản thu

## Mục đích

Ghi nhận khoản tiền thu vào.

---

## Wireframe

```

Loại thu

[▼]

────────────────────

Số tiền

[____________]

────────────────────

Ngày

[30/07/2026]

────────────────────

Giờ

[09:30]

────────────────────

Nội dung

___________________

___________________

────────────────────

[Lưu]

```

---

## Kiểm tra

Số tiền

>

0

---

Bắt buộc nhập

- Loại thu
- Số tiền

---

Sau khi lưu

↓

Hiển thị

```

Đã lưu thành công.

```

---

# 6. SCR-004 — Thêm khoản chi

Giao diện gần giống SCR-003.

Khác:

Màu đỏ.

Loại chi gồm:

- Nhập hàng
- Điện
- Nước
- Xăng xe
- Khác

---

# 7. SCR-005 — Bán hàng

## Mục đích

Tạo một phiếu bán mới.

---

## Wireframe

```

Khách hàng

[▼]

────────────────────

+ Thêm sản phẩm

────────────────────

Chứng nước

5 kg

150.000

────────────────────

Tổng tiền

750.000

────────────────────

Khách trả

[________]

────────────────────

Còn nợ

250.000

────────────────────

[Lưu]

```

---

## Thành phần

- Chọn khách hàng
- Danh sách sản phẩm
- Tổng tiền
- Tiền khách trả
- Công nợ còn lại
- Nút lưu

---

## Quy tắc

Không đủ tồn kho

↓

Không cho lưu.

---

Khách trả lớn hơn tổng tiền

↓

Hiển thị cảnh báo.

---

Sau khi lưu

↓

Hiển thị thông báo thành công.

Nếu tên khách chưa tồn tại, hệ thống yêu cầu số điện thoại và xác nhận. Ngay khi
xác nhận, khách hàng phải được lưu vào `customers` và ID vừa tạo được giữ lại để
lập phiếu bán; lỗi validation ở phần sản phẩm không được làm mất khách vừa tạo.

---

# 8. SCR-006 — Danh sách khách hàng

Hiển thị

- Tên
- Số điện thoại
- Công nợ

Có:

- Tìm kiếm
- Thêm khách
- Chỉnh sửa
- Xóa mềm; khách đã xóa không còn xuất hiện trong danh sách hoặc ô chọn bán hàng

---

# 9. SCR-007 — Chi tiết khách hàng

Hiển thị

Thông tin khách.

↓

Tổng công nợ.

↓

Lịch sử mua hàng.

↓

Lịch sử thanh toán.

Có nút

```

Thu tiền

```

---

# 10. SCR-008 — Danh sách sản phẩm

Hiển thị

- Tên
- Danh mục
- Đơn vị
- Giá mặc định
- Tồn kho

Có:

- Thêm
- Sửa
- Tìm kiếm

Khi thêm sản phẩm mới, form cho phép nhập số lượng tồn kho ban đầu. Số lượng
này được ghi vào lịch sử kho; khi sửa sản phẩm, người dùng phải dùng chức năng
Điều chỉnh kho để thay đổi tồn kho.

---

# 11. SCR-009 — Chi tiết sản phẩm

Hiển thị

- Thông tin sản phẩm
- Lịch sử nhập
- Lịch sử bán
- Tồn kho hiện tại

---

# 12. SCR-010 — Kho hàng

Danh sách

Tên sản phẩm

↓

Tồn kho

↓

Đơn vị

↓

Ngày cập nhật

Có nút

```

Nhập kho

```

và

```

Điều chỉnh

```

---

# 13. SCR-011 — Công nợ

Hiển thị

Tên khách

↓

Số nợ

↓

Ngày phát sinh gần nhất

Có bộ lọc

- Còn nợ
- Đã thanh toán

Có nút

```

Thu tiền

```

---

Mỗi thẻ ở SCR-011 mở màn hình chi tiết. Chi tiết hiển thị ngày, mặt hàng và
**còn nợ của phiếu** sau khi tính các lần thu nợ, không dùng số "đã trả" làm
thông tin chính trên thẻ.

---

# 14. SCR-012 — Backup & Restore

Hiển thị

Backup gần nhất

↓

Ngày

↓

Dung lượng

↓

Nơi lưu

Ví dụ

```

Điện thoại

Google Drive

```

Có:

```

Sao lưu ngay

```

```

Khôi phục dữ liệu

```

```

Lịch sử sao lưu

```

---

# 15. SCR-013 — Cài đặt

Bao gồm

- Cỡ chữ
- Sao lưu tự động
- Tài khoản Google Drive
- Thông tin ứng dụng
- Phiên bản Database
- Xuất dữ liệu
- Giới thiệu

---

# 16. Quy tắc điều hướng

Trang chủ

↓

Bán hàng

↓

Lưu thành công

↓

Quay về Trang chủ

---

Trang chủ

↓

Thu chi

↓

Thêm khoản thu

↓

Lưu

↓

Quay về Danh sách thu chi

---

Công nợ

↓

Chi tiết khách

↓

Thu tiền

↓

Quay về Công nợ

---

# 17. Quy tắc hiển thị

Tiền

Luôn căn phải.

---

Ngày

Định dạng

dd/MM/yyyy

---

Giờ

HH:mm

---

Số tiền

Có dấu phân cách hàng nghìn.

Ví dụ

```

2.350.000 đ

```

---

Khoản thu

Luôn màu xanh.

---

Khoản chi

Luôn màu đỏ.

---

# 18. Tổng kết

Toàn bộ giao diện được thiết kế theo tiêu chí:

- Đơn giản.
- Chữ lớn.
- Ít thao tác.
- Dễ học.
- Dễ nhìn.
- Phù hợp với người lớn tuổi.
- Có thể sử dụng hằng ngày trong môi trường buôn bán thực tế.
