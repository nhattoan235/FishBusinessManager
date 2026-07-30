# AD-014 — Sơ đồ hoạt động: UC-012B Khôi phục dữ liệu (Restore)

> Version: 2.0
>
> Last Updated: 30/07/2026

---

## Mô tả Use Case

- **Tên Use Case**: UC-012B Khôi phục dữ liệu (Restore)
- **Actor**: Chủ cửa hàng
- **Mục đích**: Khôi phục lại toàn bộ dữ liệu kinh doanh từ một bản sao lưu (Local hoặc Google Drive) khi thay điện thoại mới hoặc cần khôi phục lại thời điểm cũ. Đảm bảo an toàn tuyệt đối bằng cách tự động sao lưu dữ liệu hiện tại trước khi thực hiện restore (DP-003).

---

## Sơ đồ hoạt động PlantUML

```plantuml
@startuml
title Sơ đồ hoạt động: UC-012B Khôi phục dữ liệu (Restore)

skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #1A365D
skinparam ActivityFontName Arial
skinparam ActivityFontSize 13

start
:Người dùng mở Màn hình Sao lưu & Khôi phục (SCR-012);
:Hệ thống hiển thị danh sách các bản sao lưu có sẵn (Local & Google Drive);
:Người dùng chọn một bản sao lưu cần khôi phục và bấm "Khôi phục dữ liệu";

:Hệ thống hiển thị Hộp thoại Cảnh báo quan trọng (DP-003);
note right: "Cảnh báo: Khôi phục dữ liệu sẽ thay thế toàn bộ dữ liệu hiện tại.\nHệ thống sẽ tự động sao lưu dữ liệu hiện tại trước khi khôi phục."

if (Người dùng xác nhận đồng ý khôi phục?) then (Đồng ý)
else (Hủy)
  :Đóng hộp thoại và không thực hiện khôi phục;
  stop
endif

:Hiển thị màn hình chờ "Đang kiểm tra và khôi phục dữ liệu...";

partition "Bước 1: Kiểm tra tính hợp lệ của file Backup (DP-004)" {
  :Giải nén file .zip sao lưu vào thư mục tạm;
  :Đọc file metadata.json;

  if (Phiên bản Database trong file backup > Phiên bản App hiện tại?) then (File mới hơn App)
    :Hiển thị thông báo "Cần cập nhật ứng dụng lên phiên bản mới hơn để khôi phục dữ liệu này";
    stop
  else (Tương thích)
  endif

  :Tính mã hash SHA-256 của file database.sqlite trong gói giải nén;
  :So sánh với mã hash trong file checksum.sha256;

  if (Mã Checksum SHA-256 trùng khớp hoàn toàn?) then (Trùng khớp - Hợp lệ)
  else (Không trùng khớp - File hỏng / Bị can thiệp)
    :Hiển thị lỗi "File sao lưu bị hỏng hoặc không hợp lệ. Không thể khôi phục!";
    stop
  endif
}

partition "Bước 2: Tự động Sao lưu dữ liệu hiện tại (DP-003 An toàn)" {
  :Đóng kết nối CSDL SQLite hiện tại;
  :Tạo một bản sao lưu an toàn (Safety Backup) của dữ liệu hiện tại trước khi ghi đè;
  note right: Nếu quá trình restore bị lỗi midway,\nhệ thống sẽ tự động quay lại bản Safety Backup này.
}

partition "Bước 3: Ghi đè CSDL & Migration (nếu có)" {
  :Ghi đè file database.sqlite mới vào bộ nhớ ứng dụng;

  if (Phiên bản CSDL file restore < Phiên bản CSDL hiện tại?) then (Cần Migration)
    :Tự động chạy Migration để nâng cấp cấu trúc bảng lên phiên bản hiện tại;
  else (Cùng phiên bản)
  endif

  if (Quá trình khôi phục và Migration thành công?) then (Thành công)
    :Khởi tạo lại kết nối CSDL SQLite;
    :Ghi nhật ký khôi phục vào bảng app_logs (action = 'RESTORE_SUCCESS');
    :Hiển thị thông báo "Đã khôi phục dữ liệu thành công!";
    :Yêu cầu hoặc tự động khởi động lại giao diện ứng dụng;
    stop
  else (Thất bại / Lỗi Migration)
    :Khôi phục lại file CSDL từ bản Safety Backup đã tạo ở Bước 2;
    :Khởi tạo lại kết nối CSDL SQLite ban đầu;
    :Hiển thị lỗi "Khôi phục thất bại. Đã khôi phục lại dữ liệu ban đầu cho bạn!";
    stop
  endif
}
@enduml
```

---

## Quy tắc nghiệp vụ liên quan

| Quy tắc | Mô tả quy tắc |
|---------|---------------|
| DP-003 | Restore không được ghi đè ngay lập tức. Luôn tự động tạo bản Backup dữ liệu hiện tại trước khi Restore |
| DP-004 | File Backup phải được kiểm tra tính toàn vẹn Checksum SHA-256 trước khi khôi phục |
| DP-001 | Bảo đảm tuyệt đối không làm mất dữ liệu người dùng khi khôi phục bị lỗi |
