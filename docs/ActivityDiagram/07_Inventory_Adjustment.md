# AD-007 — Sơ đồ hoạt động: UC-010B Điều chỉnh Tồn kho (Inventory Adjustment)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-010B Điều chỉnh Tồn kho
- **Actor**: Chủ cửa hàng
- **Mục đích**: Cân bằng số lượng kho trên ứng dụng với số lượng kiểm kê thực tế khi có hao hụt, hư hỏng hoặc sai lệch. Ghi bản ghi điều chỉnh mới vào sổ cái kho (Ledger Pattern).

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-010B Điều chỉnh Tồn kho

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Kho hàng (SCR-010);
:Hệ thống hiển thị danh sách sản phẩm và Số lượng tồn kho hiện tại;
:Người dùng chọn Sản phẩm cần điều chỉnh và nhấn nút "Điều chỉnh kho";
:Hệ thống mở Form Điều chỉnh kho;

if (Loại điều chỉnh?) then (Tăng kho - Thừa thực tế)
  :Chọn Loại điều chỉnh = 'adjustment_increase';
  :Nhập Số lượng tăng thêm;
  :Nhập Lý do điều chỉnh (Kiểm kê thừa...);
else (Giảm kho - Hao hụt / Hư hỏng)
  :Chọn Loại điều chỉnh = 'adjustment_decrease';
  :Nhập Số lượng giảm đi;
  :Nhập Lý do điều chỉnh (Hao hụt, hư hỏng...);
endif

:Người dùng nhấn nút "Xác nhận điều chỉnh";

partition "Kiểm tra hợp lệ & Xác nhận (UX-003)" {
  if (Số lượng điều chỉnh > 0?) then (Không)
    :Hiển thị thông báo "Số lượng điều chỉnh phải lớn hơn 0";
    stop
  else (Có)
  endif

  if (Điều chỉnh Giảm kho và Số lượng giảm > Tồn kho hiện tại?) then (Vượt tồn kho - Vi phạm BR-802)
    :Hiển thị thông báo "Không thể điều chỉnh giảm nhiều hơn số tồn kho hiện có";
    stop
  else (Hợp lệ)
  endif

  :Hệ thống hiển thị Hộp thoại xác nhận (ConfirmDialog);
  note right: UX-003: Mọi thao tác nguy hiểm\nhoặc ảnh hưởng kho đều có bước xác nhận

  if (Người dùng bấm Xác nhận?) then (Đồng ý)
  else (Hủy thao tác)
    :Đóng hộp thoại và không thay đổi dữ liệu;
    stop
  endif
}

partition "Ghi sổ cái kho (Ledger Pattern)" {
  :Thêm bản ghi mới vào bảng inventory_entries (entry_type = 'adjustment');
  if (Thêm bản ghi thành công?) then (Có)
    :Ghi nhật ký hệ thống vào bảng app_logs;
    :Hiển thị thông báo "Đã điều chỉnh kho thành công";
    :Cập nhật lại Số lượng tồn kho mới trên Màn hình Kho hàng;
    stop
  else (Thất bại)
    :Hiển thị thông báo lỗi "Không thể điều chỉnh kho, vui lòng thử lại";
    stop
  endif
}
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-801 | Kho được quản lý theo Ledger. Không sửa lịch sử cũ, chỉ ghi bản ghi điều chỉnh mới |
| BR-802 | Không cho phép tồn kho âm |
| BR-804 | Mọi thay đổi kho đều phải ghi rõ loại biến động, sản phẩm, số lượng, thời gian và lý do |
| UX-003 | Thao tác điều chỉnh kho phải có bước xác nhận |
