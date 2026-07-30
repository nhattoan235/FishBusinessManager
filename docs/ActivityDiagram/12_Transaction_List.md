# AD-012 — Sơ đồ hoạt động: UC-002 Xem danh sách Lịch sử Thu chi (Transaction List)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-002 Xem danh sách Lịch sử Thu chi
- **Actor**: Chủ cửa hàng
- **Mục đích**: Tra cứu toàn bộ lịch sử các giao dịch thu tiền, chi tiền, thu nợ. Cho phép tìm kiếm theo từ khóa và lọc giao dịch theo mốc thời gian (Hôm nay, Tuần này, Tháng này, Khoảng ngày).

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-002 Xem danh sách Lịch sử Thu chi

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Danh sách Thu chi (SCR-002);
:Hệ thống tải danh sách giao dịch với khoảng thời gian mặc định (Hôm nay);

partition "Hiển thị và Lọc dữ liệu" {
  :Tính Tổng tiền Thu và Tổng tiền Chi trong kỳ lọc hiện tại;
  :Hiển thị Khung tóm tắt (Thu màu Xanh, Chi màu Đỏ) đầu màn hình;

  if (Người dùng chọn Bộ lọc thời gian?) then (Hôm nay)
    :Lọc giao dịch có transaction_date = Ngày hiện tại;
  elseif (Tuần này)
    :Lọc giao dịch trong 7 ngày gần nhất;
  elseif (Tháng này)
    :Lọc giao dịch trong tháng hiện tại;
  else (Khoảng ngày tùy chọn)
    :Người dùng chọn Ngày bắt đầu và Ngày kết thúc;
    :Lọc giao dịch nằm trong khoảng thời gian đã chọn;
  endif

  :Sắp xếp danh sách giao dịch: Mới nhất lên trên cùng (BR-002);
  :Hiển thị từng dòng Giao dịch (TransactionCard):
  - Icon phân biệt Thu (Xanh / +) và Chi (Đỏ / -)
  - Số tiền định dạng có dấu phân cách nghìn (2.500.000đ)
  - Nội dung mô tả / Ghi chú
  - Ngày và giờ phát sinh (dd/MM/yyyy HH:mm);
}

if (Thao tác tiếp theo của người dùng?) then (Tìm kiếm giao dịch)
  :Người dùng nhập từ khóa vào ô Tìm kiếm;
  :Hệ thống lọc danh sách theo Nội dung mô tả giao dịch;
  stop
elseif (Bấm nút Thêm giao dịch (+))
  if (Chọn loại giao dịch cần thêm?) then (Khoản Thu)
    :Chuyển sang UC-003 Thêm khoản Thu (SCR-003);
    stop
  else (Khoản Chi)
    :Chuyển sang UC-004 Thêm khoản Chi (SCR-004);
    stop
  endif
else (Bấm vào 1 dòng Giao dịch để xem chi tiết)
  :Hiển thị Hộp thoại / Sheet Chi tiết Giao dịch;
  :Hiển thị chi tiết: Loại, Số tiền, Ngày giờ, Nội dung, Phiếu bán liên quan (nếu có);
  stop
endif
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-001 | Không cho phép xóa hoặc sửa trực tiếp các giao dịch thu chi lịch sử |
| BR-002 | Mọi giao dịch lưu ngày giờ chính xác và được sắp xếp mới nhất trước |
| BR-501 | Mỗi giao dịch thu/chi là một bản ghi độc lập |
