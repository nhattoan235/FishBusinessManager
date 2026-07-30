# AD-009 — Sơ đồ hoạt động: UC-020 Quản lý Nhà cung cấp / Người bán (Supplier Management)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-020 Quản lý Nhà cung cấp (Người bán)
- **Actor**: Chủ cửa hàng
- **Mục đích**: Quản lý danh sách nơi mua chứng nước và vật tư. Toàn bộ dữ liệu do Chủ cửa hàng tự nhập thủ công (Người bán không sử dụng ứng dụng).

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-020 Quản lý Nhà cung cấp (Người bán)

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng chọn "Quản lý Người bán" từ menu Khác;
:Hệ thống mở Màn hình Danh sách Nhà cung cấp (SCR-020);

if (Thao tác mong muốn?) then (Thêm Nhà cung cấp mới - BR-201)
  :Bấm nút "Thêm người bán";
  :Hệ thống mở Form Thêm Nhà cung cấp;
  :Người dùng nhập Tên Người bán (Bắt buộc);
  :Người dùng nhập Số điện thoại, Địa chỉ, Ghi chú;
  :Bấm nút "Lưu";

  if (Tên Người bán đã được nhập?) then (Đã nhập)
    :Thêm bản ghi vào bảng suppliers (is_active = 1);
    :Hiển thị thông báo "Đã thêm người bán mới thành công";
    :Cập nhật danh sách hiển thị;
    stop
  else (Trống)
    :Hiển thị thông báo "Tên người bán không được để trống";
    stop
  endif

elseif (Chỉnh sửa thông tin - BR-203)
  :Chọn Người bán cần sửa;
  :Sửa Tên, Số điện thoại, Địa chỉ hoặc Ghi chú;
  :Bấm nút "Lưu thay đổi";
  :Cập nhật thông tin trong bảng suppliers (updated_at = Now);
  :Hiển thị thông báo "Đã cập nhật thông tin người bán";
  stop

else (Khóa / Xóa Nhà cung cấp - BR-202)
  :Chọn Người bán và bấm "Xóa / Khóa";
  if (Kiểm tra Người bán đã từng có dữ liệu nhập kho trong inventory_entries?) then (Đã từng nhập hàng - BR-202)
    :Không cho phép xóa;
    :Cập nhật trạng thái is_active = 0 (Khóa người bán);
    :Hiển thị thông báo "Đã khóa người bán (Lịch sử nhập hàng vẫn được giữ nguyên)";
    stop
  else (Chưa từng nhập hàng)
    :Xóa mềm bản ghi trong bảng suppliers (deleted_at = Now);
    :Hiển thị thông báo "Đã xóa người bán";
    stop
  endif
endif
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-201 | Nhà cung cấp được tạo hoàn toàn thủ công do người dùng nhập |
| BR-202 | Không được xóa nhà cung cấp nếu đã từng phát sinh nhập kho. Chỉ được khóa |
| BR-203 | Có thể chỉnh sửa thông tin nhà cung cấp bất cứ lúc nào |
