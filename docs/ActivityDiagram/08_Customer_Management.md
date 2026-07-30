# AD-008 — Sơ đồ hoạt động: UC-006 & UC-007 Quản lý Khách hàng (Customer Management)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-006 Danh sách Khách hàng & UC-007 Chi tiết Khách hàng
- **Actor**: Chủ cửa hàng
- **Mục đích**: Quản lý thông tin người mua hàng: xem danh sách, thêm khách hàng mới, sửa thông tin, xem chi tiết lịch sử mua bán/thanh toán và khóa khách hàng khi ngưng giao dịch.

---

## Sơ đồ hoạt động PlantUML — Thêm mới & Sửa Khách hàng

```plantuml
@startuml
title Sơ đồ hoạt động: UC-006 Thêm mới & Chỉnh sửa Khách hàng

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Danh sách Khách hàng (SCR-006);

if (Thao tác muốn thực hiện?) then (Thêm khách hàng mới)
  :Bấm nút "Thêm khách hàng";
  :Hệ thống mở Form Thêm Khách hàng;
  :Người dùng nhập Tên Khách hàng (Bắt buộc - BR-101);
  :Người dùng nhập Số điện thoại (Không bắt buộc);
  :Người dùng nhập Địa chỉ (Không bắt buộc);
  :Người dùng nhập Ghi chú (Không bắt buộc);
  :Bấm nút "Lưu Khách hàng";

  partition "Kiểm tra dữ liệu (Validation)" {
    if (Tên Khách hàng đã được nhập?) then (Trống)
      :Hiển thị thông báo "Tên khách hàng không được để trống";
      stop
    else (Đã nhập)
    endif

    if (Kiểm tra trùng Tên + Số điện thoại trong bảng customers?) then (Trùng)
      :Hiển thị thông báo "Khách hàng này đã tồn tại trong hệ thống";
      stop
    else (Không trùng)
    endif
  }

  :Thêm bản ghi mới vào bảng customers (is_active = 1);
  :Tạo bản ghi số dư nợ ban đầu = 0 vào bảng customer_balances;
  :Hiển thị thông báo "Đã thêm khách hàng thành công";
  :Cập nhật lại danh sách Khách hàng;
  stop

else (Sửa thông tin Khách hàng)
  :Chọn Khách hàng cần sửa từ danh sách;
  :Bấm nút "Chỉnh sửa thông tin";
  :Hệ thống mở Form Chỉnh sửa với thông tin hiện tại;
  :Người dùng sửa Tên, SĐT, Địa chỉ hoặc Ghi chú;
  :Bấm nút "Lưu thay đổi";

  if (Tên Khách hàng hợp lệ?) then (Hợp lệ)
    :Cập nhật thông tin vào bảng customers (updated_at = Now);
    :Hiển thị thông báo "Đã cập nhật thông tin khách hàng";
    :Cập nhật màn hình Chi tiết Khách hàng (SCR-007);
    stop
  else (Không hợp lệ)
    :Hiển thị thông báo lỗi validation;
    stop
  endif
endif
@enduml
```

---

## Sơ đồ hoạt động PlantUML — Khóa / Xóa Khách hàng (BR-103 & BR-104)

```plantuml
@startuml
title Sơ đồ hoạt động: UC-006 Khóa & Bảo vệ Lịch sử Khách hàng

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng chọn Khách hàng và bấm "Khóa / Xóa Khách hàng";

if (Hệ thống kiểm tra Khách hàng đã phát sinh giao dịch (mua hàng/nợ)?) then (Đã có giao dịch - BR-104)
  :Hệ thống KHÔNG CHO PHÉP XÓA VẬT LÝ để bảo vệ dữ liệu lịch sử;
  :Hiển thị tùy chọn "Khóa khách hàng";
  :Hiển thị Hộp thoại xác nhận (ConfirmDialog);
  note right: Khách bị khóa sẽ không xuất hiện\ntrong danh sách chọn khi bán hàng mới,\nnhưng lịch sử cũ vẫn được giữ nguyên.

  if (Người dùng bấm Xác nhận Khóa?) then (Đồng ý)
    :Cập nhật trạng thái is_active = 0 trong bảng customers;
    :Hiển thị thông báo "Đã khóa khách hàng thành công";
    :Tự động ẩn khách hàng khỏi danh sách chọn bán hàng mặc định;
    stop
  else (Hủy)
    :Giữ nguyên trạng thái khách hàng;
    stop
  endif

else (Chưa từng phát sinh giao dịch)
  :Hệ thống cho phép Khóa hoặc Xóa mềm (deleted_at = Now);
  :Thực hiện cập nhật Cơ sở dữ liệu;
  :Hiển thị thông báo hoàn tất;
  stop
endif
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-101 | Tên khách hàng là bắt buộc. Điện thoại, địa chỉ, ghi chú không bắt buộc |
| BR-102 | Được phép sửa thông tin bất cứ lúc nào, không ảnh hưởng lịch sử mua bán |
| BR-103 | Khi bị khóa: Không xuất hiện trong danh sách chọn bán hàng mới, lịch sử được giữ nguyên |
| BR-104 | Khách hàng đã phát sinh giao dịch KHÔNG được xóa khỏi hệ thống. Chỉ được khóa |
