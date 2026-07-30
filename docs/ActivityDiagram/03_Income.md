# AD-003 — Sơ đồ hoạt động: UC-003 Thêm khoản Thu (Income)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-003 Thêm khoản Thu
- **Actor**: Chủ cửa hàng
- **Mục đích**: Ghi nhận một khoản tiền thu vào tài khoản/quỹ của cửa hàng (không phải thu nợ từ khách hàng).

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-003 Thêm khoản Thu

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng chọn "Thu tiền" từ Trang chủ hoặc màn hình Thu chi;
:Hệ thống mở Màn hình Thêm khoản thu (SCR-003);

partition "Nhập thông tin khoản thu" {
  :Người dùng chọn Danh mục khoản thu (Bán hàng, Thu khác...);
  :Người dùng nhập Số tiền thu vào;
  :Hệ thống tự động điền Ngày và Giờ hiện tại;
  :Người dùng điều chỉnh Ngày/Giờ (nếu ghi nhận cho quá khứ);
  :Người dùng nhập Ghi chú nội dung (không bắt buộc);
}

:Người dùng nhấn nút "Lưu khoản thu";

partition "Kiểm tra dữ liệu (Validation)" {
  if (Danh mục khoản thu đã được chọn?) then (Chưa chọn)
    :Hiển thị thông báo "Vui lòng chọn loại khoản thu";
    stop
  else (Đã chọn)
  endif

  if (Số tiền thu > 0?) then (Không hợp lệ)
    :Hiển thị thông báo "Số tiền thu phải lớn hơn 0";
    stop
  else (Hợp lệ)
  endif
}

partition "Lưu giao dịch vào Cơ sở dữ liệu" {
  :Thêm bản ghi mới vào bảng transactions (transaction_type = 'income');
  if (Thêm bản ghi thành công?) then (Có)
    :Ghi nhật ký hệ thống vào bảng app_logs;
    :Hiển thị thông báo "Đã lưu khoản thu thành công";
    :Tự động cập nhật chỉ số "Thu hôm nay" và "Tiền hiện có" trên Dashboard;
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
| BR-501 | Mỗi lần thu tiền đều tạo một giao dịch mới, không ghi đè lên giao dịch cũ |
| BR-603 | Không cho phép số tiền thu nhỏ hơn hoặc bằng 0 |
| BR-003 | Mọi giao dịch đều hỗ trợ ghi chú để dễ tra cứu |
