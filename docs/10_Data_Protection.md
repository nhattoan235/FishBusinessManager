# 18_Data_Protection.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả toàn bộ chiến lược bảo vệ dữ liệu của ứng dụng.

Bao gồm:

- Backup
- Restore
- Kiểm tra tính toàn vẹn
- Phiên bản dữ liệu
- Chính sách lưu trữ
- Phòng chống mất dữ liệu
- Khả năng mở rộng đồng bộ trong tương lai

Mục tiêu là đảm bảo:

> Dù điện thoại bị hỏng, mất hoặc cài lại máy, dữ liệu vẫn có thể khôi phục an toàn.

---

# 2. Nguyên tắc bảo vệ dữ liệu

## DP-001

Không được mất dữ liệu do lỗi ứng dụng.

---

## DP-002

Mỗi giao dịch chỉ được lưu một lần.

---

## DP-003

Restore không được ghi đè ngay lập tức.

Luôn tạo một bản Backup của dữ liệu hiện tại trước khi Restore.

---

## DP-004

Backup phải được kiểm tra tính toàn vẹn trước khi sử dụng.

---

## DP-005

Không xóa bản Backup nếu chưa tạo thành công bản mới.

---

# 3. Kiến trúc Backup

Ứng dụng sử dụng hai tầng sao lưu.

```
SQLite

↓

Backup Local

↓

Google Drive
```

Trong đó:

Local Backup

↓

Nhanh

↓

Không cần Internet

Google Drive

↓

An toàn

↓

Phòng trường hợp mất điện thoại

---

# 4. Backup thủ công

Người dùng chọn:

```
Cài đặt

↓

Sao lưu dữ liệu

↓

Sao lưu ngay
```

Hệ thống thực hiện:

- Khóa ghi dữ liệu tạm thời.
- Kiểm tra Database.
- Sao chép Database.
- Tạo checksum.
- Nén file.
- Lưu Local.
- Nếu đã liên kết Google Drive thì tải lên.
- Ghi log.
- Thông báo hoàn thành.

---

# 5. Backup tự động

Backup tự động chạy khi:

- Kết thúc ngày.
- Sau một số lượng giao dịch nhất định (ví dụ 20 giao dịch).
- Người dùng thoát ứng dụng sau khi có thay đổi dữ liệu.

Điều kiện:

- Không chạy khi pin yếu (nếu hệ điều hành hạn chế).
- Không chạy khi đang Restore.
- Không chạy đồng thời nhiều tiến trình Backup.

---

# 6. Chính sách lưu trữ

## Local

Giữ:

- 10 bản gần nhất.

Khi tạo bản thứ 11:

↓

Xóa bản cũ nhất.

---

## Google Drive

Giữ:

- 30 bản gần nhất.

Hoặc:

- 7 bản theo ngày.
- 4 bản theo tuần.
- 12 bản theo tháng.

Điều này giúp vẫn có thể khôi phục dữ liệu của nhiều thời điểm khác nhau.

---

# 7. Định dạng Backup

Tên file:

```
backup_YYYYMMDD_HHMMSS.zip
```

Ví dụ:

```
backup_20260730_213000.zip
```

Nội dung:

```
database.sqlite

metadata.json

checksum.sha256
```

---

# 8. Metadata

Mỗi bản Backup chứa:

- Phiên bản ứng dụng.
- Phiên bản Database.
- Thời gian tạo.
- Kích thước.
- Số lượng bản ghi.
- Thiết bị tạo Backup.

Ví dụ:

```json
{
  "appVersion": "1.0.0",
  "dbVersion": 3,
  "createdAt": "2026-07-30T21:30:00Z",
  "records": 1245
}
```

---

# 9. Checksum

Sau khi Backup:

Tạo SHA-256.

Mục đích:

- Phát hiện file hỏng.
- Phát hiện chỉnh sửa trái phép.
- Kiểm tra khi Restore.

Nếu checksum không khớp:

↓

Không cho Restore.

---

# 10. Restore

Quy trình:

```
Chọn Backup

↓

Đọc Metadata

↓

Kiểm tra Version

↓

Kiểm tra Checksum

↓

Backup dữ liệu hiện tại

↓

Restore

↓

Khởi động lại ứng dụng
```

Nếu thất bại:

↓

Khôi phục lại bản Backup vừa tạo trước đó.

---

# 11. Version Database

Backup luôn chứa:

```
Database Version
```

Nếu Backup cũ hơn:

↓

Thực hiện Migration trước khi mở.

Nếu Backup mới hơn phiên bản ứng dụng:

↓

Thông báo:

"Cần cập nhật ứng dụng trước khi khôi phục dữ liệu."

---

# 12. Xử lý lỗi

## Mất kết nối Internet

Backup Local vẫn hoàn thành.

Google Drive sẽ thử tải lên ở lần tiếp theo.

---

## Thiếu dung lượng

Thông báo:

"Không đủ dung lượng để sao lưu."

Không xóa bản Backup cũ.

---

## Google Drive lỗi

Backup Local vẫn thành công.

Log lỗi để thử lại sau.

---

# 13. Bảo mật

File Backup có thể được mã hóa bằng AES-256 (giai đoạn nâng cao).

Nếu bật:

- Người dùng phải nhập mật khẩu khi Restore.

Nếu không bật:

- File chỉ dùng được trong ứng dụng.

---

# 14. Nhật ký Backup

Mỗi lần Backup hoặc Restore đều ghi log:

- Thời gian.
- Loại thao tác.
- Kết quả.
- Dung lượng.
- Thời gian thực hiện.

Ví dụ:

```
30/07/2026

21:30

Backup thành công

12 MB

5 giây
```

---

# 15. Màn hình Backup

Hiển thị:

- Backup gần nhất.
- Dung lượng.
- Vị trí lưu.
- Số lượng bản Backup.
- Trạng thái Google Drive.

Có các nút:

- Sao lưu ngay.
- Khôi phục dữ liệu.
- Xóa Backup cũ.
- Kiểm tra Backup.

---

# 16. Khả năng mở rộng

Thiết kế hiện tại cho phép mở rộng:

- Đồng bộ nhiều thiết bị.
- Đồng bộ theo thời gian thực.
- Đồng bộ lên máy chủ riêng.
- Đồng bộ với NAS gia đình.

Không cần thay đổi kiến trúc Database.

---

# 17. Kiểm thử

Kiểm thử các trường hợp:

- Backup Local.
- Backup Google Drive.
- Restore.
- File hỏng.
- Checksum sai.
- Thiếu dung lượng.
- Mất mạng.
- Migration.
- Restore từ phiên bản cũ.

---

# 18. Quy tắc phát triển

- Không Restore nếu chưa kiểm tra checksum.
- Luôn Backup trước khi Restore.
- Không xóa Backup cũ khi Backup mới thất bại.
- Không Backup khi Database đang bị khóa.
- Không Restore khi đang có Transaction chưa hoàn thành.

---

# 19. Tổng kết

Hệ thống bảo vệ dữ liệu của ứng dụng được thiết kế theo nguyên tắc:

- An toàn.
- Tự động.
- Dễ sử dụng.
- Chống mất dữ liệu.
- Có khả năng mở rộng trong tương lai.

Chiến lược Backup hai tầng (Local + Google Drive), kết hợp kiểm tra checksum, metadata và chính sách lưu trữ giúp đảm bảo dữ liệu kinh doanh luôn được bảo vệ và có thể khôi phục trong hầu hết các tình huống thực tế.
