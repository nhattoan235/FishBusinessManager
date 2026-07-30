# AD-001 — Sơ đồ hoạt động: UC-001 Xem Trang chủ (Dashboard)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-001 Xem Trang chủ (Dashboard)
- **Actor**: Chủ cửa hàng
- **Mục đích**: Tổng hợp và hiển thị tức thì các chỉ số tài chính quan trọng (Tiền hiện có, Thu hôm nay, Chi hôm nay, Khách còn nợ, Tồn kho) ngay khi mở ứng dụng.

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-001 Xem Trang chủ (Dashboard)

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở ứng dụng Fish Business Manager;

if (Kiểm tra Cơ sở dữ liệu SQLite đã khởi tạo?) then (Chưa khởi tạo)
  :Tự động chạy Seed Data;
  :Thêm Danh mục sản phẩm mặc định (Chứng nước);
  :Thêm Đơn vị tính mặc định (kg);
  :Thêm Cài đặt cấu hình ứng dụng ban đầu;
else (Đã khởi tạo)
endif

:Hệ thống tải dữ liệu tổng hợp cho Trang chủ;

partition "Tính toán chỉ số hiển thị" {
  :Tính Tiền hiện có = Tổng khoản Thu - Tổng khoản Chi toàn lịch sử;
  :Tính Thu hôm nay = Tổng giao dịch Thu trong ngày hiện tại;
  :Tính Chi hôm nay = Tổng giao dịch Chi trong ngày hiện tại;
  :Tính Khách còn nợ = Tổng dư nợ hiện tại từ các khách hàng;
  :Tính Tồn kho = Tổng số lượng các sản phẩm còn trong kho;
}

:Hiển thị màn hình Trang chủ (SCR-001) với đầy đủ thông tin chỉ số;

if (Người dùng chọn thao tác nào tiếp theo?) then (Chuyển đến Màn hình Bán hàng)
  :Mở UC-005 Tạo phiếu Bán hàng (SCR-005);
elseif (Chọn Thêm khoản thu) then
  :Mở UC-003 Thêm khoản Thu (SCR-003);
elseif (Chọn Thêm khoản chi) then
  :Mở UC-004 Thêm khoản Chi (SCR-004);
elseif (Chọn tab Thu chi) then
  :Mở UC-002 Xem danh sách Thu chi (SCR-002);
elseif (Chọn tab Công nợ) then
  :Mở UC-011A Xem tổng quan Công nợ (SCR-011);
else (Chọn tab Khác / Cài đặt)
  :Mở UC-013 Cài đặt ứng dụng (SCR-013);
endif

stop
@enduml
```

---

## Dữ liệu hiển thị

| Thành phần | Bảng dữ liệu nguồn | Công thức / Điều kiện |
|------------|---------------------|------------------------|
| Tiền hiện có | `transactions` | SUM(amount WHERE transaction_type='income') - SUM(amount WHERE transaction_type='expense') |
| Thu hôm nay | `transactions` | SUM(amount) WHERE transaction_type='income' AND transaction_date=Today |
| Chi hôm nay | `transactions` | SUM(amount) WHERE transaction_type='expense' AND transaction_date=Today |
| Khách còn nợ | `customer_balances` | SUM(current_debt) WHERE current_debt > 0 |
| Tồn kho | `inventory_entries` | Tổng biến động kho theo sản phẩm |
