# AD-011 — Sơ đồ hoạt động: UC-011A Xem tổng quan Công nợ (Debt Overview)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-011A Xem tổng quan Công nợ
- **Actor**: Chủ cửa hàng
- **Mục đích**: Theo dõi danh sách khách hàng đang thiếu nợ, sắp xếp theo số nợ nhiều/ít, trực quan hóa màu sắc (Đỏ = Nợ nhiều, Xanh = Đã thanh toán) để chủ cửa hàng quản lý thu nợ hiệu quả.

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-011A Xem tổng quan Công nợ

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Công nợ (SCR-011);
:Hệ thống tải dữ liệu tổng hợp nợ từ bảng customer_balances;
:Hệ thống tính Tổng dư nợ công nợ của toàn bộ cửa hàng;

partition "Lọc và Trực quan hóa dữ liệu" {
  if (Người dùng chọn Bộ lọc?) then (Khách còn nợ - Mặc định)
    :Lọc danh sách khách hàng có current_debt > 0;
    :Sắp xếp Khách nợ nhiều nhất lên đầu trang;
  elseif (Khách đã thanh toán xong)
    :Lọc danh sách khách hàng có current_debt = 0;
  else (Tất cả khách hàng)
    :Hiển thị tất cả khách hàng trong hệ thống;
  endif

  :Hiển thị thẻ thông tin Khách hàng (CustomerCard);
  note right: Phân màu trực quan (UX spec):\n- Dư nợ lớn (>= 1.000.000đ): Hiển thị màu Đỏ\n- Dư nợ nhỏ (< 1.000.000đ): Hiển thị màu Cam\n- Dư nợ = 0đ: Hiển thị màu Xanh lá
}

if (Người dùng tương tác với thẻ Khách hàng?) then (Bấm vào thẻ Khách hàng)
  :Chuyển sang Màn hình Chi tiết Khách hàng (SCR-007);
  :Hiển thị Lịch sử Mua hàng và Lịch sử Thanh toán nợ;
  stop
elseif (Bấm nút "Thu tiền" trên thẻ)
  :Mở UC-011 Ghi nhận Thu nợ Khách hàng (SCR-011 Form);
  :Thực hiện luồng thu nợ;
  stop
else (Tìm kiếm khách hàng)
  :Người dùng nhập Tên hoặc Số điện thoại vào ô Tìm kiếm;
  :Lọc danh sách tức thì theo từ khóa nhập vào;
  stop
endif
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| BR-701 | Công nợ chỉ phát sinh khi khách chưa thanh toán đủ số tiền mua hàng |
| BR-702 | Mọi thay đổi công nợ đều phải lưu lịch sử trong `debt_transactions` |
| BR-703 | Bảng `customer_balances` lưu dư nợ hiện tại để hiển thị danh sách công nợ nhanh chóng |
