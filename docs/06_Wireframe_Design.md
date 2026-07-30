# 06_Wireframe_Design.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Draft

---

# 1. Mục tiêu

Tài liệu này mô tả bố cục (Wireframe) của toàn bộ ứng dụng.

Wireframe không tập trung vào màu sắc hay hình ảnh mà chỉ mô tả:

- Vị trí các thành phần
- Luồng thao tác
- Thứ tự hiển thị
- Thông tin cần hiển thị

Tất cả màn hình đều phải tuân thủ tài liệu này trước khi thiết kế giao diện chi tiết.

---

# 2. Danh sách màn hình

| Mã | Màn hình | Bắt buộc |
|------|---------------------|----------|
| WF01 | Splash | Có |
| WF02 | Trang chủ | Có |
| WF03 | Bán hàng | Có |
| WF04 | Ghi giao dịch | Có |
| WF05 | Danh sách giao dịch | Có |
| WF06 | Chi tiết giao dịch | Có |
| WF07 | Người mua | Có |
| WF08 | Thêm/Sửa người mua | Có |
| WF09 | Người bán | Có |
| WF10 | Kho | Có |
| WF11 | Công nợ | Có |
| WF12 | Báo cáo | Có |
| WF13 | Sao lưu | Có |
| WF14 | Cài đặt | Có |

---

# WF01 - Splash

```

```
┌──────────────────────────┐
│                          │
│                          │
│          LOGO            │
│                          │
│ Fish Business Manager    │
│                          │
│      Đang khởi động...   │
│                          │
└──────────────────────────┘

```

Thời gian hiển thị

≤ 2 giây.

---

# WF02 - Trang chủ

```

```
┌─────────────────────────────┐

Tiền hiện có

15.300.000đ

──────────────────────────────

┌────────┬────────┬────────┐
│ 🛒     │ 💰     │ 💸     │
│ Bán    │ Thu    │ Chi    │
└────────┴────────┴────────┘

──────────────────────────────

Thu hôm nay

2.500.000đ

Chi hôm nay

800.000đ

──────────────────────────────

Hàng còn

Khách còn nợ

──────────────────────────────

Giao dịch gần đây

🟢 Thu

🔴 Chi

🟢 Thu

──────────────────────────────

Thanh điều hướng

Trang chủ

Kho

Báo cáo

Thêm

Cài đặt

```

```

---

Các nguyên tắc

Tiền hiện có luôn hiển thị đầu tiên.

Ba nút:

- Bán
- Thu
- Chi

luôn hiển thị giữa màn hình.

---

# WF03 - Bán hàng

```

```
← Bán hàng

────────────────────

Người mua

[ Chọn ]

────────────────────

Số lượng

[          ]

────────────────────

Đơn giá

[          ]

────────────────────

Khách trả

[          ]

────────────────────

Tổng tiền

250.000đ

────────────────────

Còn nợ

0đ

────────────────────

[      LƯU      ]

```

```

Nếu chỉ có một loại hàng thì không hiển thị trường "Loại hàng".

---

# WF04 - Ghi giao dịch

```

```
← Giao dịch

────────────────────

○ Thu

○ Chi

────────────────────

Số tiền

[            ]

────────────────────

Ngày

30/07/2026

────────────────────

Giờ

09:35

────────────────────

Nội dung

[...................]

────────────────────

[      LƯU      ]

```

```

Nếu chọn

Thu

↓

Màu xanh.

Nếu chọn

Chi

↓

Màu đỏ.

---

# WF05 - Danh sách giao dịch

```

```
← Giao dịch

[Tìm kiếm........]

────────────────────

Lọc

Ngày

Tháng

Năm

Thu

Chi

────────────────────

🟢 Thu

300.000đ

09:30

Bán chứng nước

────────────────────

🔴 Chi

120.000đ

10:15

Đổ xăng

────────────────────

```

```

Mỗi giao dịch là một Card.

Không dùng Table.

---

# WF06 - Chi tiết giao dịch

```

```
← Chi tiết

────────────────────

Loại

Thu

────────────────────

Số tiền

300.000đ

────────────────────

Ngày

30/07/2026

────────────────────

Giờ

09:30

────────────────────

Nội dung

Bán chứng nước

────────────────────

[Sửa]

[Xóa]

```

```

---

# WF07 - Người mua

```

```
← Người mua

[Tìm kiếm]

────────────────────

Nguyễn Văn A

Nợ

300.000đ

────────────────────

Trần Văn B

Đã thanh toán

────────────────────

( + )

```

```

---

# WF08 - Thêm / Sửa người mua

```

```
← Người mua

Tên

[          ]

SĐT

[          ]

Địa chỉ

[          ]

Ghi chú

[..........]

──────────────

[LƯU]

```

```

---

# WF09 - Người bán

Giống màn hình Người mua.

Không hiển thị công nợ.

---

# WF10 - Kho

```

```
← Kho

────────────────────

Hàng còn

15 kg

────────────────────

Nguồn

○ Mua

○ Thu hoạch

────────────────────

Số lượng

[      ]

────────────────────

[LƯU]

```

```

---

# WF11 - Công nợ

```

```
← Công nợ

[Tìm kiếm]

────────────────────

Nguyễn Văn A

Nợ

500.000đ

[Thu nợ]

────────────────────

```

```

Khi bấm Thu nợ

↓

Mở Bottom Sheet.

---

# WF12 - Báo cáo

```

```
← Báo cáo

────────────────────

○ Ngày

○ Tháng

○ Năm

────────────────────

Tổng thu

Tổng chi

Tiền lời

Khách còn nợ

Hàng còn

```

```

---

# WF13 - Sao lưu

```

```
← Sao lưu

────────────────────

Lần gần nhất

09:00

30/07/2026

────────────────────

[Sao lưu ngay]

────────────────────

Các bản sao lưu

09:00

29/07

28/07

...

```

```

---

# WF14 - Cài đặt

```

```
← Cài đặt

──────────────

Kích thước chữ

>

──────────────

Khôi phục dữ liệu

>

──────────────

Thông tin ứng dụng

>

──────────────

Phiên bản

1.0.0

```

```

---

# 3. Bottom Navigation

```

```
┌───────────────────────────┐

🏠

Trang chủ

📦

Kho

📊

Báo cáo

➕

Thêm

⚙️

Cài đặt

└───────────────────────────┘

```

```

---

# 4. Bottom Sheet

Sử dụng cho:

- Chọn người mua
- Chọn người bán
- Chọn ngày
- Thu nợ

Không dùng Dialog cho các danh sách dài.

---

# 5. Dialog

Chỉ dùng khi:

- Xóa
- Khôi phục
- Đặt lại dữ liệu

Không dùng Dialog để nhập dữ liệu.

---

# 6. Floating Action Button

Chỉ xuất hiện ở các màn hình:

- Người mua
- Người bán
- Danh sách giao dịch

Mục đích

Thêm mới.

---

# 7. Empty State

Ví dụ

Không có giao dịch

↓

Hiển thị

📄

"Chưa có giao dịch nào."

Không để màn hình trống.

---

# 8. Error State

Ví dụ

Không đọc được dữ liệu

↓

Hiển thị

⚠️

"Không thể tải dữ liệu."

[Kết nối lại]

---

# 9. Loading State

Hiển thị

Skeleton Loading

Không khóa toàn bộ màn hình nếu không cần.

---

# 10. Kết luận

Wireframe là tài liệu mô tả cấu trúc của từng màn hình.

Trong giai đoạn này chỉ tập trung vào vị trí thành phần và luồng thao tác.

Màu sắc, typography và animation được định nghĩa trong tài liệu UI/UX Guideline.

---

# 11. Quy tắc màn hình Bán hàng

Màn hình Bán hàng phải hoàn thành toàn bộ thao tác trên **một màn hình duy nhất**.

Không chia thành nhiều bước hoặc nhiều màn hình.

Lý do:

- Giảm số lần chạm.
- Giảm nhầm lẫn.
- Người lớn tuổi dễ sử dụng hơn.

Thứ tự nhập liệu:

1. Người mua
2. Số lượng
3. Đơn giá
4. Khách đã trả
5. Ghi chú (không bắt buộc)

Hệ thống tự động hiển thị:

- Tổng tiền
- Còn nợ
- Hàng còn

Người dùng không cần tự tính toán.

Ví dụ

```
┌─────────────────────────────┐

← Bán hàng

──────────────────────────────

Người mua

[ Nguyễn Văn A ]

──────────────────────────────

Số lượng

[ 10 ]

──────────────────────────────

Đơn giá

[ 30.000 ]

──────────────────────────────

Khách đã trả

[ 200.000 ]

──────────────────────────────

Tổng tiền

300.000đ

──────────────────────────────

Khách còn nợ

100.000đ

──────────────────────────────

Kho còn

120 kg

──────────────────────────────

[      LƯU      ]

└─────────────────────────────┘
```

---

# 12. Quick Action (Thao tác nhanh)

Trang chủ luôn hiển thị ba nút thao tác lớn.

```
┌──────────────┬──────────────┬──────────────┐
│      🛒      │      💰      │      💸      │
│   Bán hàng   │      Thu     │      Chi     │
└──────────────┴──────────────┴──────────────┘
```

Ba nút này luôn nằm ở vị trí dễ bấm nhất trên màn hình.

Người dùng có thể thực hiện các thao tác chính mà không cần mở menu.

---

# 13. Quick Transaction Bottom Sheet

Khi nhấn nút **Thu** hoặc **Chi** từ Trang chủ.

Không mở màn hình mới.

Hệ thống hiển thị Bottom Sheet.

Ví dụ

```
────────────────────────────

Thu tiền

────────────────────────────

Số tiền

[____________]

────────────────────────────

Nội dung

[____________]

────────────────────────────

Ngày

30/07/2026

────────────────────────────

Giờ

09:35

────────────────────────────

[      LƯU      ]

────────────────────────────
```

Mặc định:

- Ngày = Hôm nay
- Giờ = Hiện tại

Người dùng vẫn có thể chỉnh sửa nếu cần.

Sau khi lưu:

- Bottom Sheet tự đóng.
- Trang chủ cập nhật ngay.
- Hiển thị thông báo "Đã lưu thành công."

---

# 14. Thiết kế Card trên Trang chủ

Thông tin quan trọng phải được hiển thị bằng Card.

Không dùng danh sách văn bản đơn thuần.

Ví dụ

```
┌──────────────────────────────┐
│ 💵 Tiền hiện có              │
│ 15.300.000đ                  │
└──────────────────────────────┘

┌─────────────┬─────────────┐
│ 🟢 Thu hôm nay │ 🔴 Chi hôm nay │
│ 2.500.000đ     │ 800.000đ       │
└─────────────┴─────────────┘

┌─────────────┬─────────────┐
│ 📦 Hàng còn │ 👤 Khách nợ │
│ 125 kg      │ 3 người     │
└─────────────┴─────────────┘

┌──────────────────────────────┐
│ 🛒 Bán hàng  💰 Thu  💸 Chi   │
└──────────────────────────────┘

────────── Giao dịch gần đây ──────────
🟢 Thu ...
🔴 Chi ...

════════ Bottom Navigation ════════
🏠  📦  📊  ⚙️
```

Card phải có:

- Bo góc.
- Khoảng cách đều nhau.
- Icon rõ ràng.
- Font lớn.
- Không chứa quá nhiều thông tin.

---

# 15. Giao dịch gần đây

Ngay dưới phần Card.

Hiển thị tối đa 10 giao dịch.

Ví dụ

```
────────────────────────────

09:30

🟢 Thu

300.000đ

Bán chứng nước

────────────────────────────

10:15

🔴 Chi

150.000đ

Đổ xăng

────────────────────────────
```

Mỗi giao dịch là một Card.

Bấm vào Card để xem chi tiết.

Vuốt sang trái để hiện:

- Sửa
- Xóa (đưa vào Thùng rác)

---

# 16. Floating Action Button

Floating Action Button chỉ dùng cho:

- Thêm người mua
- Thêm người bán
- Thêm giao dịch

Không dùng FAB cho chức năng:

- Thu
- Chi
- Bán hàng

Vì các chức năng này đã có Quick Action trên Trang chủ.

---

# 17. Nguyên tắc thao tác

Mọi chức năng sử dụng hằng ngày phải hoàn thành trong tối đa 3 lần chạm.

Ví dụ

Thu tiền

Trang chủ

↓

Thu

↓

Nhập tiền

↓

Lưu

Hoàn thành.

---

Bán hàng

Trang chủ

↓

Bán hàng

↓

Nhập thông tin

↓

Lưu

Hoàn thành.

---

Không được tạo các bước xác nhận không cần thiết.

Chỉ yêu cầu xác nhận đối với các thao tác có nguy cơ làm mất dữ liệu.

---

# 18. Kết luận

Wireframe phải ưu tiên:

- Ít màn hình.
- Ít thao tác.
- Thông tin rõ ràng.
- Font lớn.
- Card trực quan.
- Người lớn tuổi có thể thao tác nhanh và chính xác.

Mọi thay đổi Wireframe phải được cập nhật trong tài liệu này trước khi triển khai giao diện thực tế.
