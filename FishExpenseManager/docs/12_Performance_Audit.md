# Performance Audit - Fish Expense Manager

## Mục tiêu
Tạo tài liệu kiểm tra nhanh cho phần ứng dụng Flutter trong `FishExpenseManager/mobile`, tập trung vào hiệu năng tải trang, truy vấn database và các màn hình chính.

## Kết quả kiểm tra hiện tại

### 1. Database và provider
- `ReportRepositoryImpl` hiện đang tải toàn bộ `transactions` cho năm/tháng/thời gian cần tính toán rồi xử lý bằng Dart.
- `profitSummaryProvider`, `monthlyStatsProvider`, `dailyStatsProvider` dùng `customSelect('SELECT COUNT(*) ...').watch().asyncMap(...)` để kích hoạt làm mới.
- `DashboardRepositoryImpl.watchDashboardSummary()` dùng `Stream.periodic(Duration(seconds: 5))` thay vì sử dụng reactive query thật sự.
- `DatabaseProvider` tạo `AppDatabase` mỗi khi provider được đọc và đóng khi dispose; đây là đúng nhưng cần kiểm tra việc mở DB cục bộ.
- Schema hiện không có index rõ ràng cho các trường dùng trong lọc/đếm nhiều lần.

### 2. Tăng tốc màn hình
- Màn hình danh sách (`TransactionListScreen`, `ProductListScreen`, `InventoryDashboardScreen`, `SupplierListScreen`, `CustomerListScreen`) đang lọc/search trên toàn bộ dữ liệu trong bộ nhớ.
- Điều này sẽ tốn bộ nhớ và làm chậm khi dữ liệu lớn.
- Một số màn hình report dùng `SingleChildScrollView` với `...map(...)` để tạo nhiều widget, thay vì dùng `ListView.builder` hoặc widgets tĩnh.

### 3. Khởi động và backend nền
- `main.dart` chờ `DatabaseEncryptionService().getOrCreateKey()` trước khi gọi `runApp()`.
- `initializeBackgroundBackup()` cũng được gọi trước khi ứng dụng nạp UI.
- Nếu `FlutterSecureStorage` hoặc Workmanager chậm, app sẽ delay khởi động.

## Vấn đề cụ thể cần sửa

### Database / truy vấn
- Thêm chỉ mục cho:
  - `transactions(date)`
  - `inventory_entries(product_id)`
  - `sale_documents(customer_id)`
  - `debt_transactions(customer_id)`
- Refactor các truy vấn báo cáo sang SQL aggregate/groupped ngay trong database.
- Tránh sử dụng `Stream.periodic` cho dashboard summary.
- Tránh query toàn bộ transaction khi chỉ cần số liệu tổng hợp.

### UI và provider
- Đưa search/filter xuống database để tránh load toàn bộ list.
- Nếu dùng search trực tiếp trên list, cần debounce và filter trên DB.
- Dùng `ListView.builder` hoặc `SliverList` thay vì `Column(children: [...])` cho danh sách lớn.
- Tách state search/filter ra provider riêng để giảm rebuild không cần thiết.

### Startup
- Chạy `initializeBackgroundBackup()` không cần chặn sau khi app hiển thị (điều kiện an toàn).
- Hiển thị splash/loading sớm nếu phải chờ key mã hóa.
- Kiểm tra `FlutterSecureStorage` và `Workmanager` có thể làm app start chậm.

## Đề xuất hành động ưu tiên

1. Refactor `ReportRepositoryImpl` sang truy vấn SQL group-by.
2. Chuyển `DashboardSummaryProvider` sang reactive watch trên bảng `transactions`.
3. Thêm index cho cột `date` và cột khóa ngoại quan trọng.
4. Cải thiện tìm kiếm/lọc trên các màn hình danh sách bằng query DB.
5. Giảm thời gian khởi tạo app bằng cách không chặn UI với backup hoặc key-loading.

## Kiểm tra sau sửa

- [ ] Dashboard load nhanh hơn, không còn refresh 5 giây cố định.
- [ ] Report show dữ liệu nhanh hơn khi có nhiều giao dịch.
- [ ] Danh sách filter/search không lag khi gõ.
- [ ] App start được ngay sau khi chạy `runApp()`.
- [ ] Truy vấn database có index phù hợp và không scan bảng lớn.

## Gợi ý cải thiện tiếp theo

- Xem lại `customerHistoryProvider` và chuyển sang reactive stream trực tiếp.
- Xem lại `TransactionRepositoryImpl.getTransactions()` nếu cần filter theo ngày/khoảng.
- Dùng `const` nhiều hơn trong widget để giảm chi phí rebuild.
- Xem xét cache data nếu báo cáo không cần realtime 100%.
