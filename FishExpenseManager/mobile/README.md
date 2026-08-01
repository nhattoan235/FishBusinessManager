# Fish Business Manager Mobile

## Cấu hình Google Drive trên Android

Google Drive cần OAuth credentials của dự án Google Cloud; client ID không được
đóng cứng vào mã nguồn.

1. Tạo hoặc chọn một Google Cloud project bằng tài khoản quản trị của ứng dụng.
2. Trong **APIs & Services > Library**, bật **Google Drive API**.
3. Trong **Google Auth Platform > Branding/Audience**, tạo màn hình đồng ý:
   - App name: `Fish Business Manager`.
   - Audience: `External`.
   - Khi ứng dụng còn ở trạng thái Testing, thêm email Drive lưu trữ vào danh
     sách **Test users**.
4. Tạo OAuth client loại **Android**:
   - Package: `com.fishbusinessmanager.app`.
   - SHA-1 của bản debug hiện tại:
     `42:8A:08:E9:00:20:A4:6A:C5:65:5B:A2:30:A5:66:28:61:53:FA:9E`.
   - Bản release phải tạo thêm Android client với SHA-1 của release keystore.
5. Tạo OAuth client loại **Web application**. Không cần điền JavaScript origin
   hoặc redirect URI cho luồng Android này. Sao chép **Client ID** của Web
   client; đây chính là `GOOGLE_SERVER_CLIENT_ID`.
6. Cài ứng dụng, vào **Cài đặt > Google Drive > Nhập Client ID**, dán Web
   Client ID rồi chọn **Lưu và kết nối**. Client ID được giữ trong Secure
   Storage và không cần build lại.

Có thể đóng gói sẵn Client ID khi build nếu không muốn nhập trên thiết bị:

```powershell
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
flutter build apk --release --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

Không đưa **Client secret** vào ứng dụng. Native app chỉ cần Client ID.

### Dùng một email riêng để nhận backup

Google Cloud project xác định ứng dụng nào được phép đăng nhập; nó không quyết
định Drive nào nhận file. File backup luôn được tải lên tài khoản mà người dùng
chọn ở nút **Kết nối Google Drive**.

1. Tạo một Google Account riêng chỉ để lưu dữ liệu, ví dụ
   `fishbusiness.backup@...`.
2. Thêm email này làm Test user nếu OAuth app đang ở trạng thái Testing.
3. Cài APK đã build kèm `GOOGLE_SERVER_CLIENT_ID` lên điện thoại của ba mẹ.
4. Vào **Cài đặt > Google Drive > Kết nối**.
5. Trong cửa sổ chọn tài khoản, chọn đúng email backup; nếu chưa xuất hiện thì
   chọn **Thêm tài khoản khác** và đăng nhập email đó.
6. Kiểm tra email hiển thị trong màn Cài đặt, rồi bấm **Sao lưu ngay**.
7. Mở Drive của email backup và kiểm tra thư mục
   `Fish Business Manager Backups`.

Ứng dụng dùng scope `drive.file`, vì vậy chỉ quản lý các file/thư mục mà chính
ứng dụng đã tạo; ứng dụng không được đọc toàn bộ Drive. Nếu bấm **Ngắt kết nối**,
thu hồi quyền trong Google Account hoặc xóa dữ liệu ứng dụng thì cần kết nối lại.

Có thể dùng `google-services.json` thay cho Dart define nếu dự án được cấu hình
Firebase/Google Services đầy đủ và file có OAuth Web client (`client_type: 3`).

## Cơ chế sao lưu

- Bản sao lưu là ZIP gồm database snapshot, metadata và checksum SHA-256.
- Tối đa 10 bản gần nhất được giữ trên máy và 30 bản trên Google Drive.
- Khi mất mạng, bản local vẫn được giữ và upload Drive nằm trong hàng chờ.
- Trước khi restore, ứng dụng kiểm tra checksum và tạo một safety backup.
- Sao lưu tự động chỉ chạy khi dữ liệu đã thay đổi, dựa trên thời gian, số giao
  dịch hoặc khi ứng dụng chuyển sang nền.
