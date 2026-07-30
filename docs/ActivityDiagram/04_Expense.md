# AD-004 — Sơ đồ hoạt động: UC-004 Thêm khoản Chi (Expense)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-004 Thêm khoản Chi
- **Actor**: Chủ cửa hàng
- **Mục đích**: Ghi nhận một khoản chi tiêu của cửa hàng (tiền mua hàng, tiền điện, nước, xăng xe, chi phí nuôi cá...).

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-004 Thêm khoản Chi

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng chọn "Thêm khoản chi" từ Trang chủ hoặc màn hình Thu chi;
:Hệ thống mở Màn hình Thêm khoản chi (SCR-004) với giao diện màu đỏ;

partition "Nhập thông tin khoản chi" {
  :Người dùng chọn Danh mục chi (Nhập hàng, Điện, Nước, Xăng xe, Chi khác...);
  :Người dùng nhập Số tiền chi ra;
  :Hệ thống tự động điền Ngày và Giờ hiện tại;
  :Người dùng điều chỉnh Ngày/Giờ (nếu chi trong quá khứ);
  :Người dùng nhập Nội dung ghi chú (bắt buộc theo BR-601);
}

:Người dùng nhấn nút "Lưu khoản chi";

partition "Kiểm tra dữ liệu (Validation)" {
  if (Danh mục khoản chi đã được chọn?) then (Chưa chọn)
    :Hiển thị thông báo "Vui lòng chọn loại khoản chi";
    stop
  else (Đã chọn)
  endif

  if (Số tiền chi > 0?) then (Không hợp lệ)
    :Hiển thị thông báo "Số tiền chi phải lớn hơn 0";
    stop
  else (Hợp lệ)
  endif

  if (Nội dung chi đã được nhập?) then (Trống)
    :Hiển thị thông báo "Vui lòng nhập nội dung cho khoản chi";
    stop
  else (Đã nhập)
  endif
}

partition "Lưu giao dịch vào Cơ sở dữ liệu" {
  :Thêm bản ghi mới vào bảng transactions (transaction_type = 'expense');
  if (Thêm bản ghi thành công?) then (Có)
    :Ghi nhật ký hệ thống vào bảng app_logs;
    :Hiển thị thông báo "Đã lưu khoản chi thành công";
    :Tự động cập nhật chỉ số "Chi hôm nay" và "Tiền hiện có" trên Dashboard;
    :Quay lại màn hình Danh sách Thu chi (SCR-002);
    stop
  else (Thất bại)
    :Hiển thị thông báo lỗi "Không thể lưu giao dịch, vui lòng thử lại";
    stop
  endif
}
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-601 | Mọi khoản chi đều phải có: Loại chi, Số tiền, Ngày, Nội dung |
| BR-602 | Các loại chi được quản lý theo danh mục |
| BR-603 | Không cho phép số tiền chi nhỏ hơn hoặc bằng 0 |
