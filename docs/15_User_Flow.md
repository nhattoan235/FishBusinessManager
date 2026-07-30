# 15_User_Flow.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả các luồng sử dụng (User Flow) của người dùng trong thực tế.

Mục tiêu là giảm tối đa:

- Số lần chạm.
- Số màn hình phải đi qua.
- Thời gian nhập liệu.
- Sai sót khi thao tác.

Đối tượng sử dụng chính là chủ cửa hàng và người lớn tuổi.

---

# 2. Nguyên tắc thiết kế User Flow

## UF-001

Một công việc nên hoàn thành trong tối đa **3–5 bước**.

---

## UF-002

Không yêu cầu người dùng nhớ thông tin.

Ứng dụng phải hiển thị và gợi ý đầy đủ.

---

## UF-003

Mỗi thao tác xong đều quay về màn hình phù hợp để tiếp tục công việc.

---

## UF-004

Ưu tiên thao tác bằng một tay.

Các nút chính đặt ở nửa dưới màn hình.

---

# 3. Luồng số 1 - Mở ứng dụng

```
Mở ứng dụng

↓

Hiển thị Dashboard

↓

Xem nhanh

• Tiền hiện có

• Thu hôm nay

• Chi hôm nay

• Công nợ

• Kho

↓

Chọn chức năng
```

Không yêu cầu đăng nhập mỗi lần mở ứng dụng.

---

# 4. Luồng số 2 - Bán hàng (Luồng quan trọng nhất)

```
Dashboard

↓

Bán hàng

↓

Chọn khách

↓

Thêm sản phẩm

↓

Nhập số lượng

↓

Nhập số tiền khách trả

↓

Lưu

↓

Thông báo thành công

↓

Quay lại Dashboard
```

Nếu khách chưa trả đủ:

```
↓

Tự động tạo công nợ

↓

Quay Dashboard
```

Người dùng không cần mở màn hình Công nợ để ghi thêm.

---

# 5. Luồng số 3 - Thu tiền khách nợ

```
Dashboard

↓

Công nợ

↓

Chọn khách

↓

Thu tiền

↓

Nhập số tiền

↓

Lưu

↓

Thông báo

↓

Quay lại Công nợ
```

Nếu khách trả hết:

Hiển thị:

```
Đã thanh toán xong.
```

---

# 6. Luồng số 4 - Ghi khoản chi

```
Dashboard

↓

Thu chi

↓

+

↓

Khoản chi

↓

Nhập thông tin

↓

Lưu

↓

Quay danh sách
```

---

# 7. Luồng số 5 - Ghi khoản thu khác

Ví dụ:

- Bán đồ cũ.
- Thu tiền khác.

```
Dashboard

↓

Thu chi

↓

+

↓

Khoản thu

↓

Nhập thông tin

↓

Lưu
```

---

# 8. Luồng số 6 - Nhập kho

```
Kho

↓

Nhập kho

↓

Chọn sản phẩm

↓

Nhập số lượng

↓

Chọn nguồn

↓

Lưu

↓

Kho cập nhật
```

Nguồn nhập gồm:

- Mua từ nhà cung cấp.
- Tự sản xuất.

---

# 9. Luồng số 7 - Thêm khách hàng

```
Khách hàng

↓

+

↓

Nhập tên

↓

Lưu
```

Các thông tin khác như:

- Điện thoại
- Địa chỉ
- Ghi chú

Có thể nhập sau.

---

# 10. Luồng số 8 - Backup

```
Cài đặt

↓

Sao lưu dữ liệu

↓

Kiểm tra

↓

Tạo Backup

↓

Lưu vào máy

↓

Nếu đã kết nối Google Drive

↓

Upload

↓

Thông báo hoàn thành
```

---

# 11. Luồng số 9 - Restore

```
Cài đặt

↓

Khôi phục dữ liệu

↓

Chọn Backup

↓

Kiểm tra

↓

Xác nhận

↓

Khôi phục

↓

Khởi động lại ứng dụng
```

---

# 12. Luồng số 10 - Xem doanh thu

```
Dashboard

↓

Thu chi

↓

Lọc

↓

Tháng

↓

Hiển thị

Thu

Chi

Lợi nhuận
```

---

# 13. Luồng số 11 - Xem công nợ

```
Dashboard

↓

Công nợ

↓

Danh sách khách

↓

Chi tiết

↓

Lịch sử
```

---

# 14. Luồng số 12 - Xem tồn kho

```
Dashboard

↓

Kho

↓

Danh sách

↓

Chi tiết sản phẩm
```

---

# 15. Luồng số 13 - Tìm kiếm

Có thể tìm kiếm từ:

- Khách hàng
- Sản phẩm
- Thu chi
- Công nợ

Người dùng chỉ cần nhập:

```
Tên

↓

Hoặc

Số điện thoại
```

---

# 16. Luồng số 14 - Cuối ngày

Sau khi bán xong.

Người dùng thường:

```
Mở Dashboard

↓

Kiểm tra

Thu hôm nay

↓

Chi hôm nay

↓

Tiền hiện có

↓

Công nợ
```

Không cần mở nhiều màn hình.

---

# 17. Điều hướng tổng thể

```
Dashboard

├── Thu chi

│      ├── Thu

│      └── Chi

│

├── Bán hàng

│

├── Công nợ

│      └── Thu tiền

│

├── Kho

│      └── Nhập kho

│

└── Cài đặt

       ├── Backup

       └── Restore
```

---

# 18. Nguyên tắc tối ưu thao tác

- Không quá 3 lần chạm cho thao tác thường dùng.
- Luôn hiển thị nút quay lại rõ ràng.
- Sau khi lưu, quay về màn hình trước thay vì Trang chủ (trừ Bán hàng).
- Không yêu cầu nhập lại dữ liệu đã có.
- Tự động điền ngày và giờ hiện tại.
- Tự động ghi nhớ lựa chọn gần nhất khi phù hợp (ví dụ nguồn nhập kho).

---

# 19. Tình huống thực tế

## Tình huống 1

Khách mua 10 kg chứng nước.

↓

Trả 200.000đ.

↓

Còn nợ 300.000đ.

Người dùng chỉ cần:

Bán hàng

↓

Lưu

Hệ thống tự động:

- Trừ kho.
- Ghi thu.
- Ghi công nợ.

---

## Tình huống 2

Buổi chiều mua thêm thức ăn.

↓

Vào

Thu chi

↓

Khoản chi

↓

Nhập

↓

Lưu.

---

## Tình huống 3

Khách quay lại trả nợ.

↓

Mở

Công nợ

↓

Chọn khách

↓

Thu tiền

↓

Lưu.

---

# 20. Tổng kết

User Flow của ứng dụng được thiết kế theo nguyên tắc:

- Đơn giản.
- Nhanh.
- Ít bước.
- Phù hợp thói quen buôn bán hằng ngày.
- Hạn chế tối đa thao tác dư thừa.
- Người lớn tuổi có thể sử dụng sau thời gian làm quen ngắn mà không cần ghi nhớ quy trình phức tạp.
