# AD-010 — Sơ đồ hoạt động: UC-008 & UC-009 Quản lý Sản phẩm (Product Management)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-008 Danh sách Sản phẩm & UC-009 Chi tiết Sản phẩm
- **Actor**: Chủ cửa hàng
- **Mục đích**: Quản lý danh mục sản phẩm kinh doanh (Chứng nước, Cá giống, Thức ăn, Thuốc, Vật tư), gắn Đơn vị tính tương ứng (kg, bao, con, thùng) và thiết lập Giá bán mặc định.

---

## Sơ đồ hoạt động PlantUML — Thêm mới & Quản lý Sản phẩm

```plantuml
@startuml
title Sơ đồ hoạt động: UC-008 & UC-009 Quản lý Sản phẩm

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Danh sách Sản phẩm (SCR-008);

if (Thao tác muốn thực hiện?) then (Thêm Sản phẩm mới)
  :Bấm nút "Thêm sản phẩm";
  :Hệ thống mở Form Thêm Sản phẩm;
  :Người dùng nhập Tên Sản phẩm;
  :Người dùng chọn Danh mục sản phẩm (bảng product_categories) - BR-301;
  :Người dùng chọn Đơn vị tính mặc định (bảng units) - BR-302;
  :Người dùng nhập Giá bán mặc định (không bắt buộc);
  :Bấm nút "Lưu Sản phẩm";

  partition "Kiểm tra dữ liệu (Validation)" {
    if (Tên, Danh mục và Đơn vị tính đã được chọn đầy đủ?) then (Chưa đủ)
      :Hiển thị thông báo "Vui lòng nhập đầy đủ thông tin bắt buộc";
      stop
    else (Đầy đủ)
    endif

    if (Kiểm tra trùng Tên sản phẩm trong cùng Danh mục?) then (Trùng tên)
      :Hiển thị thông báo "Tên sản phẩm đã tồn tại trong danh mục này";
      stop
    else (Không trùng)
    endif
  }

  :Thêm bản ghi mới vào bảng products (is_active = 1);
  :Hiển thị thông báo "Đã thêm sản phẩm mới thành công";
  :Cập nhật danh sách hiển thị trên SCR-008;
  stop

elseif (Xem chi tiết Sản phẩm - UC-009)
  :Chọn Sản phẩm từ danh sách;
  :Hệ thống mở Màn hình Chi tiết Sản phẩm (SCR-009);
  :Tải Lịch sử Bán hàng của sản phẩm từ sale_items;
  :Tải Lịch sử Nhập kho của sản phẩm từ inventory_entries;
  :Hiển thị Số lượng Tồn kho hiện tại của sản phẩm;
  stop

else (Ngừng kinh doanh Sản phẩm - BR-303 & BR-304)
  :Chọn Sản phẩm và bấm "Ngừng kinh doanh";
  if (Kiểm tra Sản phẩm đã phát sinh giao dịch bán hoặc kho?) then (Đã từng phát sinh - BR-304)
    :KHÔNG CHO PHÉP XÓA VẬT LÝ;
    :Cập nhật trạng thái is_active = 0 trong bảng products (BR-303);
    :Hiển thị thông báo "Đã chuyển sản phẩm sang trạng thái Ngừng kinh doanh";
    note right: Sản phẩm sẽ không hiển thị khi tạo phiếu bán hàng mới,\nnhưng toàn bộ lịch sử bán/kho cũ vẫn được lưu giữ an toàn.
    stop
  else (Chưa từng phát sinh giao dịch)
    :Cho phép xóa bản ghi sản phẩm khỏi CSDL;
    :Hiển thị thông báo "Đã xóa sản phẩm thành công";
    stop
  endif
endif
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-301 | Một sản phẩm thuộc đúng một danh mục (`product_categories`) |
| BR-302 | Một sản phẩm có một đơn vị tính mặc định (`units`) |
| BR-303 | Sản phẩm ngừng kinh doanh: Không xuất hiện khi bán mới, giữ nguyên lịch sử |
| BR-304 | Không được xóa sản phẩm đã từng phát sinh giao dịch bán hoặc kho |
