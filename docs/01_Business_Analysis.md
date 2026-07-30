# 01_Business_Analysis.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Draft

---

# 1. Giới thiệu

Tài liệu này mô tả toàn bộ quy trình nghiệp vụ của hệ thống quản lý buôn bán chứng nước.

Đây là tài liệu nền tảng để:

- Xây dựng Use Case.
- Thiết kế Database.
- Thiết kế giao diện.
- Phát triển phần mềm.

Mọi thay đổi về nghiệp vụ đều phải được cập nhật vào tài liệu này trước khi lập trình.

---

# 2. Mô hình kinh doanh

Gia đình hoạt động theo mô hình:

```text
                 Người bán
                     │
                     │
                     ▼
              Mua chứng nước
                     │
                     │
                     ▼
                  Kho hàng
                     ▲
                     │
         Thu hoạch chứng nước
                     │
                     │
              Khu nuôi cá
                     │
                     ▼
                Chủ cửa hàng
                     │
                     ▼
                Bán cho khách
                     │
          ┌──────────┴──────────┐
          │                     │
      Trả đủ tiền          Ghi nợ
          │                     │
          ▼                     ▼
      Thu tiền             Công nợ
```

---

# 3. Các bên tham gia

Hiện tại hệ thống chỉ có một người sử dụng.

## Chủ cửa hàng

Là người thực hiện toàn bộ nghiệp vụ.

Bao gồm:

- Quản lý người mua
- Quản lý người bán
- Quản lý hàng
- Ghi nhận thu
- Ghi nhận chi
- Bán hàng
- Thu nợ
- Xem báo cáo
- Sao lưu dữ liệu

---

# 4. Đối tượng quản lý

Hệ thống quản lý các nhóm dữ liệu sau.

## Người mua

Lưu thông tin khách hàng.

Bao gồm:

- Tên
- Số điện thoại (không bắt buộc)
- Địa chỉ (không bắt buộc)
- Ghi chú

---

## Người bán

Lưu thông tin nơi mua chứng nước.

Lưu ý:

Người bán KHÔNG sử dụng ứng dụng.

Toàn bộ dữ liệu do Chủ cửa hàng tự nhập.

---

## Sản phẩm

Phiên bản đầu tiên chỉ có:

- Chứng nước

Tuy nhiên hệ thống được thiết kế để sau này có thể mở rộng thêm sản phẩm khác.

Ví dụ:

- Cá giống
- Thức ăn
- Thuốc
- Vật tư

---

## Kho

Quản lý số lượng hàng còn.

Nguồn nhập kho gồm:

- Mua từ người bán
- Thu hoạch từ khu nuôi

---

## Giao dịch

Một giao dịch là:

- Một lần thu tiền

hoặc

- Một lần chi tiền

Không tồn tại giao dịch vừa thu vừa chi.

---

## Công nợ

Quản lý khoản tiền khách còn thiếu.

Không quản lý công nợ với người bán trong phiên bản đầu tiên.

---

# 5. Quy trình nghiệp vụ

## 5.1 Bán hàng

```text
Chọn người mua
      │
      ▼
Chọn sản phẩm
      │
      ▼
Nhập số lượng
      │
      ▼
Kiểm tra hàng còn
      │
      ▼
Tính tiền
      │
      ▼
Khách thanh toán?
      │
 ┌────┴─────┐
 │          │
Có         Không đủ
 │          │
 ▼          ▼
Thu tiền   Ghi nợ
 │          │
 └────┬─────┘
      ▼
Giảm hàng trong kho
      ▼
Hoàn thành
```

---

## 5.2 Thu tiền

```text
Mở màn hình Thu tiền

↓

Nhập số tiền

↓

Nhập nội dung

↓

Lưu

↓

Tiền hiện có tăng
```

---

## 5.3 Chi tiền

```text
Mở màn hình Chi tiền

↓

Nhập số tiền

↓

Nhập nội dung

↓

Lưu

↓

Tiền hiện có giảm
```

---

## 5.4 Thu nợ

```text
Mở danh sách khách còn nợ

↓

Chọn khách

↓

Nhập số tiền trả

↓

Cập nhật công nợ

↓

Sinh giao dịch Thu
```

---

## 5.5 Nhập hàng

Có hai nguồn.

### Mua từ người bán

```text
Người bán

↓

Nhập số lượng

↓

Nhập kho
```

---

### Thu hoạch

```text
Khu nuôi

↓

Thu hoạch

↓

Nhập kho
```

---

# 6. Sổ tiền

Đây là màn hình được sử dụng nhiều nhất.

Mục đích:

Giúp chủ cửa hàng biết ngay tình hình tài chính.

Hiển thị:

- Tiền hiện có
- Thu hôm nay
- Chi hôm nay
- Lịch sử giao dịch

Ví dụ:

```text
=========================

Tiền hiện có

15.300.000đ

Thu hôm nay

2.500.000đ

Chi hôm nay

800.000đ

=========================

09:15

🟢 Thu

300.000

Bán chứng nước

----------------

10:20

🔴 Chi

120.000

Đổ xăng

```

---

# 7. Quy trình sao lưu

Ứng dụng không yêu cầu người dùng nhớ sao lưu.

Hệ thống sẽ tự động thực hiện.

Điều kiện sao lưu:

- Khi đóng ứng dụng.
- Sau khoảng thời gian định kỳ.
- Sau số lượng giao dịch nhất định.
- Khi người dùng chọn "Sao lưu ngay".

Bản sao lưu sẽ được lưu:

- Trong điện thoại.
- Google Drive (khi có Internet).

Nếu mất mạng:

Bản sao lưu sẽ được đưa vào hàng chờ.

Khi có mạng:

Tự động tải lên.

---

# 8. Quy trình khôi phục

Người dùng chọn:

Khôi phục dữ liệu

↓

Hệ thống kiểm tra file

↓

Tự tạo bản sao lưu hiện tại

↓

Khôi phục

↓

Kiểm tra thành công

↓

Thông báo hoàn tất

Nếu lỗi:

Không thay đổi dữ liệu hiện tại.

---

# 9. Những điều KHÔNG làm

Phiên bản đầu tiên sẽ không có:

- Hóa đơn điện tử
- Quét mã QR
- Máy in
- Đồng bộ nhiều điện thoại
- Website
- Đăng nhập nhiều tài khoản
- Thanh toán trực tuyến

---

# 10. Các nguyên tắc nghiệp vụ

## Một giao dịch chỉ thuộc một loại

Hoặc:

- Thu

Hoặc:

- Chi

Không tồn tại cả hai.

---

## Không cho phép số tiền âm.

---

## Không cho phép bán vượt số lượng hàng còn.

---

## Thu nợ luôn tạo giao dịch Thu.

---

## Bán thiếu luôn sinh công nợ.

---

## Mọi thay đổi dữ liệu đều được lưu vào nhật ký hệ thống.

---

## Khôi phục dữ liệu luôn tạo bản sao lưu trước.

---

# 11. Những quyết định sau khảo sát thực tế

Sau khi khảo sát mô hình kinh doanh của gia đình, nhóm phát triển thống nhất:

- Không sử dụng hóa đơn giấy.
- Không quản lý hóa đơn điện tử.
- Người bán không sử dụng ứng dụng.
- Chủ cửa hàng thực hiện toàn bộ thao tác.
- Giao diện sử dụng ngôn ngữ đời thường.
- Chữ lớn, màu sắc rõ ràng.
- Hạn chế thuật ngữ kế toán.
- Ưu tiên tốc độ nhập liệu hơn số lượng chức năng.
- Toàn bộ nghiệp vụ chính phải hoạt động khi không có Internet.

---

# 12. Kết luận

Hệ thống được xây dựng để phục vụ một mô hình kinh doanh cụ thể thay vì cố gắng trở thành phần mềm bán hàng đa năng.

Mọi chức năng trong các tài liệu tiếp theo phải tuân thủ đúng các nghiệp vụ được mô tả trong tài liệu này.

Không được bổ sung chức năng mới nếu chưa đánh giá ảnh hưởng đến nghiệp vụ hiện có.
