# AD-013 — Sơ đồ hoạt động: UC-012A Sao lưu dữ liệu (Backup)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-012A Sao lưu dữ liệu (Backup)
- **Actor**: Chủ cửa hàng / Tiến trình tự động hệ thống
- **Mục đích**: Nén toàn bộ cơ sở dữ liệu SQLite, tạo checksum SHA-256 xác thực tính toàn vẹn, lưu bản sao lưu ở bộ nhớ máy tính/điện thoại (Local) và tự động đồng bộ lên Google Drive (Cloud) nhằm bảo vệ dữ liệu chống mất mát (DP-001).

---

## Sơ đồ hoạt động PlantUML — Sao lưu thủ công

```plantuml
@startuml
title Sơ đồ hoạt động: UC-012A Sao lưu dữ liệu (Chủ động / Thủ công)

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Sao lưu & Khôi phục (SCR-012);
:Người dùng bấm nút "Sao lưu ngay";
:Hệ thống hiển thị Hộp thoại xác nhận sao lưu;

if (Người dùng bấm Xác nhận?) then (Đồng ý)
else (Hủy)
  :Đóng hộp thoại;
  stop
endif

:Hiển thị màn hình chờ "Đang tiến hành sao lưu dữ liệu...";

partition "Kiểm tra điều kiện an toàn" {
  if (Có tiến trình Sao lưu khác đang chạy?) then (Đang chạy)
    :Hiển thị thông báo "Đang có tiến trình sao lưu khác chạy, vui lòng đợi";
    stop
  else (Khổng)
  endif

  if (Bộ nhớ lưu trữ thiết bị còn đủ dung lượng?) then (Không đủ)
    :Hiển thị thông báo "Không đủ dung lượng bộ nhớ để tạo bản sao lưu";
    stop
  else (Đủ dung lượng)
  endif
}

partition "Tạo bản Sao lưu Local (Zip & Checksum)" {
  :Tạm thời khóa quyền ghi vào Cơ sở dữ liệu SQLite;
  :Tạo bản sao chép (Snapshot) của file database.sqlite vào thư mục tạm;
  :Mở khóa quyền ghi CSDL SQLite;

  :Tạo file metadata.json (Phiên bản app, DB version, Ngày tạo, Số lượng bản ghi);
  :Tính mã hash SHA-256 của file database.sqlite (DP-004);
  :Tạo file checksum.sha256 chứa mã hash;
  :Nén 3 file (database.sqlite, metadata.json, checksum.sha256) thành file .zip;
  note right: Định dạng tên file:\nfish_business_backup_YYYYMMDD_HHmmss.zip

  :Xác minh lại mã checksum SHA-256 của file .zip vừa tạo;
  if (Checksum hợp lệ?) then (Hợp lệ)
    :Lưu file .zip vào thư mục backups/ trong bộ nhớ thiết bị;
    :Ghi nhật ký sao lưu thành công vào bảng backup_logs (status = 'completed');
  else (Lỗi file hỏng)
    :Xóa file zip tạm;
    :Ghi log thất bại vào backup_logs;
    :Hiển thị thông báo lỗi "Tạo file sao lưu thất bại do lỗi dữ liệu";
    stop
  endif
}

partition "Chính sách dọn dẹp Local & Đồng bộ Google Drive (Cloud)" {
  :Kiểm tra số lượng bản sao lưu trong bộ nhớ Local;
  if (Số lượng bản backup local > 10 bản?) then (Vượt quá 10 bản)
    :Tự động xóa bản sao lưu cũ nhất để tiết kiệm dung lượng máy;
  else (<= 10 bản)
  endif

  if (Người dùng đã bật liên kết Google Drive và có kết nối Internet?) then (Có mạng & Đã kết nối)
    :Tải file .zip vừa tạo lên thư mục ứng dụng trên Google Drive;
    if (Upload lên Drive thành công?) then (Thành công)
      :Cập nhật trạng thái storage = 'drive' trong bảng backup_logs;
    else (Thất bại / Mất mạng)
      :Lưu file vào Hàng chờ tải lên (Upload Queue) để thử lại sau;
    endif
  else (Không có mạng / Chưa bật)
    :Bỏ qua bước upload Cloud;
  endif
}

:Hiển thị thông báo "Đã sao lưu dữ liệu thành công!";
:Cập nhật thông tin Lần sao lưu gần nhất trên Màn hình SCR-012;
stop
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| DP-001 | Không được làm mất dữ liệu do bất kỳ lỗi ứng dụng nào |
| DP-004 | File Backup phải được kiểm tra tính toàn vẹn (Checksum SHA-256) trước khi công nhận thành công |
| DP-005 | Không xóa bản Backup cũ nếu bản Backup mới chưa được tạo thành công hoàn toàn |
| Policy | Bộ nhớ Local giữ tối đa 10 bản sao lưu gần nhất. Google Drive giữ 30 bản gần nhất |
