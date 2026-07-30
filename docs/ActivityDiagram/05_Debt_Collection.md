# AD-005 — Sơ đồ hoạt động: UC-011 Ghi nhận Thu nợ Khách hàng (Debt Collection)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-011 Ghi nhận Thu nợ Khách hàng
- **Actor**: Chủ cửa hàng
- **Mục đích**: Ghi nhận việc khách hàng thanh toán tiền nợ cũ. Tự động giảm dư nợ khách hàng, tạo lịch sử nợ và sinh giao dịch thu tiền vào sổ cái.

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-011 Ghi nhận Thu nợ Khách hàng

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Công nợ (SCR-011) hoặc Màn hình Chi tiết Khách hàng (SCR-007);
:Hệ thống hiển thị Danh sách Khách hàng đang có dư nợ (> 0 đồng);
:Người dùng chọn Khách hàng cần thu nợ;
:Hệ thống hiển thị Thông tin Khách hàng và Tổng số nợ hiện tại (current_debt);
:Người dùng nhấn nút "Thu tiền nợ";

:Hệ thống mở Form Thu nợ;
:Người dùng nhập Số tiền Khách trả lần này;
:Người dùng nhập Ghi chú (nếu có);
:Người dùng nhấn nút "Xác nhận thu nợ";

partition "Kiểm tra hợp lệ (Validation)" {
  if (Số tiền trả > 0?) then (Không)
    :Hiển thị thông báo "Số tiền thu nợ phải lớn hơn 0";
    stop
  else (Có)
  endif

  if (Số tiền trả <= Số nợ hiện tại?) then (Vượt nợ - Vi phạm BR-503)
    :Hiển thị thông báo "Số tiền thu không được vượt quá tổng số công nợ còn lại";
    stop
  else (Hợp lệ)
  endif
}

partition "Database Transaction (Cập nhật Thu nợ)" {
  :Mở Database Transaction trong SQLite;

  :Thêm bản ghi thu tiền vào bảng transactions (transaction_type = 'collect_debt');
  if (Thêm transactions thành công?) then (Có)
  else (Thất bại)
    goto rollback_label
  endif

  :Thêm bản ghi giảm nợ vào bảng debt_transactions (change_type = 'decrease');
  if (Thêm debt_transactions thành công?) then (Có)
  else (Thất bại)
    goto rollback_label
  endif

  :Cập nhật giảm dư nợ trong bảng customer_balances (current_debt -= số tiền trả);
  if (Cập nhật customer_balances thành công?) then (Có)
  else (Thất bại)
    goto rollback_label
  endif

  :COMMIT Database Transaction;
  :Hệ thống hiển thị thông báo "Đã thu nợ thành công";

  if (Số nợ còn lại sau khi thu > 0?) then (Còn nợ)
    :Hiển thị thông báo "Khách còn nợ lại: X đồng";
  else (Hết nợ)
    :Hiển thị thông báo "Khách hàng đã thanh toán hết nợ";
  endif

  :Cập nhật lại danh sách Công nợ trên màn hình;
  stop

  label rollback_label
  :ROLLBACK Database Transaction;
  :Hiển thị lỗi "Không thể ghi nhận thu nợ, hệ thống đã hoàn tác";
  stop
}
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-501 | Mỗi lần thu tiền đều tạo một giao dịch mới, không ghi đè |
| BR-502 | Một khách hàng có thể trả nhiều lần cho cùng một phiếu bán hoặc khoản nợ |
| BR-503 | Không được thu vượt quá số công nợ còn lại |
| BR-702 | Mọi thay đổi công nợ đều phải lưu lịch sử trong `debt_transactions` |
| BR-703 | Số dư công nợ `customer_balances` chỉ là dữ liệu tổng hợp |
