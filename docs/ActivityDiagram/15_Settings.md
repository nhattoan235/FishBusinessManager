# AD-015 — Sơ đồ hoạt động: UC-013 Cài đặt ứng dụng (Settings)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-013 Cài đặt cấu hình ứng dụng
- **Actor**: Chủ cửa hàng
- **Mục đích**: Tùy chỉnh các thiết lập hệ thống: Cỡ chữ hiển thị (font_scale), Sao lưu tự động (auto_backup), Liên kết tài khoản Google Drive, Thời gian giữ bản sao lưu và xem thông tin phiên bản ứng dụng.

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-013 Cài đặt cấu hình ứng dụng

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng chọn "Cài đặt" từ menu Khác;
:Hệ thống đọc cấu hình hiện tại từ bảng app_settings (id = 1);
:Hiển thị Màn hình Cài đặt (SCR-013);

if (Người dùng chọn thay đổi cấu hình nào?) then (Thay đổi Cỡ chữ hiển thị - font_scale)
  :Người dùng chọn Cỡ chữ (Bình thường / Chữ lớn / Chữ rất lớn);
  :Hệ thống cập nhật cột font_scale trong bảng app_settings;
  :Áp dụng ngay Cỡ chữ mới lên toàn bộ giao diện ứng dụng;
  stop

elseif (Bật / Tắt Sao lưu tự động - auto_backup)
  :Người dùng gạt công tắc Bật/Tắt Sao lưu tự động;
  :Cập nhật cột auto_backup (0 hoặc 1) trong bảng app_settings;
  if (Bật sao lưu tự động?) then (Bật)
    :Kích hoạt Tiến trình hẹn giờ sao lưu tự động (Background Service);
  else (Tắt)
    :Hủy Tiến trình hẹn giờ sao lưu tự động;
  endif
  stop

elseif (Cấu hình Google Drive Backup)
  if (Trạng thái liên kết hiện tại?) then (Chưa liên kết)
    :Người dùng bấm "Kết nối Google Drive";
    :Mở luồng Đăng nhập Google (OAuth2 Google Sign-In);
    if (Đăng nhập và cấp quyền thành công?) then (Thành công)
      :Lưu thông tin tài khoản Google vào cài đặt;
      :Cập nhật use_google_drive = 1 trong app_settings;
      :Hiển thị thông báo "Đã kết nối tài khoản Google thành công";
    else (Thất bại / Hủy)
      :Hiển thị thông báo "Kết nối tài khoản Google thất bại";
    endif
  else (Đã kết nối)
    :Người dùng bấm "Hủy kết nối Google Drive";
    :Xóa thông tin đăng nhập Google khỏi secure storage;
    :Cập nhật use_google_drive = 0 trong app_settings;
    :Hiển thị thông báo "Đã ngắt kết nối Google Drive";
  endif
  stop

else (Xem thông tin Ứng dụng & CSDL)
  :Hiển thị Tên ứng dụng, Phiên bản App (v1.0.0), Phiên bản CSDL (v1);
  :Hiển thị Thông tin Giới thiệu và Hướng dẫn sử dụng;
  stop
endif
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| DB Config | Bảng `app_settings` chỉ có duy nhất 1 dòng dữ liệu (`id = 1`) lưu cấu hình hệ thống |
| Accessibility | Phông chữ hỗ trợ phóng to (Font Scale) giúp người lớn tuổi dễ thao tác |
