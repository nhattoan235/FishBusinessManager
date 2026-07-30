# 05_UI_UX_Design.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả tiêu chuẩn thiết kế giao diện (UI) và trải nghiệm người dùng (UX) của ứng dụng quản lý thu chi và bán hàng.

Mục tiêu quan trọng nhất là:

> **Người lớn tuổi cũng có thể sử dụng dễ dàng mà không cần học nhiều.**

Ứng dụng ưu tiên:

- Đơn giản
- Dễ nhìn
- Dễ bấm
- Ít thao tác
- Hạn chế nhập liệu
- Không gây rối mắt

---

# 2. Đối tượng sử dụng

Ứng dụng dành cho:

- Chủ cửa hàng
- Người lớn tuổi
- Không am hiểu công nghệ
- Thường sử dụng điện thoại Android

Đặc điểm người dùng:

- Thị lực giảm
- Thao tác chậm
- Không quen các thuật ngữ kỹ thuật
- Muốn thao tác nhanh

---

# 3. Nguyên tắc thiết kế

## UX-001

Mỗi màn hình chỉ nên có **một nhiệm vụ chính**.

Ví dụ:

Màn hình Bán hàng

↓

Chỉ tập trung bán hàng.

Không chứa cài đặt.

---

## UX-002

Không hiển thị quá nhiều thông tin cùng lúc.

Ưu tiên:

Thông tin quan trọng

↓

Thông tin phụ

↓

Thông tin chi tiết

---

## UX-003

Mỗi thao tác quan trọng đều phải có xác nhận.

Ví dụ:

- Xóa
- Restore
- Backup
- Điều chỉnh kho

---

## UX-004

Các nút bấm phải đủ lớn.

Kích thước tối thiểu:

48dp × 48dp

---

## UX-005

Không sử dụng thuật ngữ kỹ thuật.

Ví dụ

Không dùng

```
Transaction
```

Dùng

```
Thu tiền
```

Không dùng

```
Inventory
```

Dùng

```
Kho hàng
```

Không dùng

```
Restore Database
```

Dùng

```
Khôi phục dữ liệu
```

---

# 4. Màu sắc

## Thu

Màu xanh.

Ví dụ

```
#2E7D32
```

---

## Chi

Màu đỏ.

Ví dụ

```
#C62828
```

---

## Cảnh báo

Màu cam.

Ví dụ

```
#F57C00
```

---

## Thành công

Màu xanh lá.

---

## Lỗi

Màu đỏ.

---

## Thông tin

Màu xanh dương.

---

## Nền

Ưu tiên:

- Trắng
- Xám rất nhạt

Không dùng nền quá tối.

---

# 5. Chữ

## Font

Google Sans

hoặc

Roboto

---

## Cỡ chữ

Tiêu đề lớn

24sp

---

Tiêu đề

20sp

---

Nội dung

18sp

---

Ghi chú

16sp

---

Không sử dụng chữ nhỏ hơn

16sp

---

## Độ đậm

Tiêu đề

Bold

---

Tên khách

Semi Bold

---

Số tiền

Bold

---

Nội dung

Regular

---

# 6. Icon

Ưu tiên Material Design Icon.

Ví dụ

Thu

↓

attach_money

---

Chi

↓

money_off

---

Kho

↓

inventory

---

Khách hàng

↓

person

---

Nhà cung cấp

↓

local_shipping

---

Backup

↓

backup

---

Restore

↓

restore

---

Không dùng icon khó hiểu.

---

# 7. Điều hướng

Ứng dụng sử dụng

Bottom Navigation.

Gồm 5 tab.

```
Trang chủ

↓

Thu chi

↓

Bán hàng

↓

Công nợ

↓

Khác
```

---

Tab hiện tại luôn được tô màu.

---

Không sử dụng Drawer.

---

# 8. Dashboard

Đây là màn hình đầu tiên.

Hiển thị:

- Tiền hiện có
- Hôm nay thu
- Hôm nay chi
- Công nợ còn lại
- Tồn kho
- Nút thao tác nhanh

---

Ví dụ

```
==========================

Tiền hiện có

15.600.000 đ

--------------------------

Hôm nay

Thu

+2.500.000

Chi

-800.000

--------------------------

Khách còn nợ

3.200.000

--------------------------

Kho

350 kg

==========================
```

---

# 9. Màn hình Thu chi

Danh sách hiển thị dạng thẻ (Card).

Mỗi dòng gồm:

- Màu
- Số tiền
- Nội dung
- Ngày
- Giờ

Ví dụ

```
🟢

+500.000

Bán chứng nước

30/07/2026

09:30
```

---

Khoản chi

```
🔴

-300.000

Mua thức ăn

30/07/2026

11:20
```

---

Có bộ lọc:

- Hôm nay
- Tuần này
- Tháng này
- Theo khoảng ngày

---

Có ô tìm kiếm.

---

# 10. Màn hình Bán hàng

Các bước nhập liệu:

1.

Chọn khách hàng.

↓

2.

Chọn sản phẩm.

↓

3.

Nhập số lượng.

↓

4.

Nhập đơn giá.

↓

5.

Nhập số tiền khách trả (nếu có).

↓

6.

Lưu.

---

Sau khi lưu:

Hiển thị:

```
Đã lưu thành công
```

---

Nếu còn nợ:

Hiển thị:

```
Khách còn nợ

250.000 đ
```

---

# 11. Màn hình Công nợ

Danh sách khách hàng.

Hiển thị:

Tên

↓

Số nợ

↓

Ngày giao dịch gần nhất

---

Khách nợ nhiều

↓

Màu đỏ.

---

Đã thanh toán

↓

Màu xanh.

---

Nhấn vào

↓

Xem lịch sử.

---

# 12. Màn hình Kho

Hiển thị:

Tên sản phẩm

↓

Đơn vị

↓

Tồn kho

↓

Ngày cập nhật gần nhất

---

Có nút

```
Nhập kho
```

và

```
Điều chỉnh
```

---

# 13. Màn hình Backup

Hiển thị

Backup gần nhất

↓

Thời gian

↓

Dung lượng

↓

Nơi lưu

Ví dụ

```
Điện thoại

Google Drive
```

---

Có nút

```
Sao lưu ngay
```

---

Có nút

```
Khôi phục dữ liệu
```

---

Có danh sách các bản sao lưu.

---

# 14. Thông báo

Thông báo luôn ngắn gọn.

Ví dụ

Đúng

```
Đã lưu thành công.
```

Sai

```
Thao tác đã được hệ thống xử lý thành công.
```

---

Ví dụ

```
Không đủ tồn kho.
```

```
Tên khách hàng không được để trống.
```

```
Đã sao lưu dữ liệu.
```

---

# 15. Hiệu ứng

Không dùng hiệu ứng phức tạp.

Ưu tiên:

- Fade
- Slide nhẹ

Thời gian:

200–300 ms.

---

# 16. Khả năng truy cập (Accessibility)

Ứng dụng cần hỗ trợ:

- Chữ lớn.
- Độ tương phản cao.
- Vùng chạm lớn.
- Không phụ thuộc màu sắc để truyền đạt thông tin.

Ví dụ:

Ngoài màu xanh và đỏ, luôn kèm theo dấu "+" hoặc "-" trước số tiền để người dùng dễ nhận biết.

---

# 17. Nguyên tắc nhập liệu

Giảm tối đa việc gõ bàn phím.

Ưu tiên:

- Danh sách chọn.
- Nút tăng/giảm.
- Tự động điền.
- Gợi ý dữ liệu đã nhập trước đó.

Ví dụ:

Khi bán hàng, sau khi chọn sản phẩm, hệ thống tự điền:

- Đơn vị tính.
- Giá mặc định (nếu có).

Người dùng chỉ cần chỉnh sửa khi cần.

---

# 18. Tổng kết

Toàn bộ giao diện của ứng dụng được thiết kế theo các tiêu chí:

- Đơn giản.
- Dễ học.
- Dễ thao tác.
- Chữ lớn, rõ ràng.
- Màu sắc trực quan.
- Phù hợp với người lớn tuổi.
- Tập trung vào tốc độ và độ chính xác khi ghi nhận thu chi, bán hàng và công nợ.
