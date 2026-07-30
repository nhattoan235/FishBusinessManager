# AD-006 — Sơ đồ hoạt động: UC-010A Nhập kho Hàng hóa (Inventory Import)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-010A Nhập kho Hàng hóa
- **Actor**: Chủ cửa hàng
- **Mục đích**: Ghi nhận số lượng hàng hóa (Chứng nước / sản phẩm khác) tăng thêm vào kho từ hai nguồn: Mua từ Nhà cung cấp hoặc Thu hoạch từ Khu nuôi cá gia đình.

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-010A Nhập kho Hàng hóa

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Kho hàng (SCR-010);
:Người dùng nhấn nút "Nhập kho";
:Hệ thống mở Form Nhập kho;

if (Người dùng chọn Nguồn nhập kho?) then (Mua từ Nhà cung cấp)
  :Chọn Nguồn = 'purchase';
  :Chọn Sản phẩm cần nhập;
  :Chọn Nhà cung cấp (từ danh sách suppliers);
  :Nhập Số lượng hàng mua vào;
  :Nhập Đơn giá mua (không bắt buộc);
  :Nhập Ghi chú (không bắt buộc);
else (Thu hoạch từ Khu nuôi)
  :Chọn Nguồn = 'harvest';
  :Chọn Sản phẩm thu hoạch;
  :Nhập Số lượng hàng thu hoạch;
  :Nhập Ghi chú (không bắt buộc);
endif

:Người dùng nhấn nút "Lưu nhập kho";

partition "Kiểm tra hợp lệ (Validation)" {
  if (Sản phẩm đã được chọn?) then (Chưa chọn)
    :Hiển thị thông báo "Vui lòng chọn sản phẩm nhập kho";
    stop
  else (Đã chọn)
  endif

  if (Nguồn nhập là 'purchase' và chưa chọn Nhà cung cấp?) then (Chưa chọn)
    :Hiển thị thông báo "Vui lòng chọn Nhà cung cấp";
    stop
  else (Đã chọn / Nguồn khác)
  endif

  if (Số lượng nhập > 0?) then (Không hợp lệ)
    :Hiển thị thông báo "Số lượng nhập kho phải lớn hơn 0";
    stop
  else (Hợp lệ)
  endif
}

partition "Lưu sổ cái kho (Ledger Pattern)" {
  :Thêm bản ghi biến động tăng kho vào bảng inventory_entries (entry_type = 'purchase' hoặc 'harvest');
  if (Thêm bản ghi thành công?) then (Có)
    :Ghi nhật ký hệ thống vào bảng app_logs;
    :Hiển thị thông báo "Đã nhập kho thành công";
    :Cập nhật số lượng Tồn kho mới trên Màn hình Kho hàng;
    stop
  else (Thất bại)
    :Hiển thị thông báo lỗi "Không thể lưu dữ liệu nhập kho";
    stop
  endif
}
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-801 | Kho được quản lý theo Ledger. Chỉ thêm bản ghi mới, không sửa lịch sử |
| BR-803 | Các nguồn nhập kho gồm: Mua từ nhà cung cấp (`purchase`), Tự sản xuất (`harvest`), Điều chỉnh (`adjustment`) |
| BR-804 | Mọi thay đổi kho đều phải ghi rõ: Loại biến động, Sản phẩm, Số lượng, Thời gian |
