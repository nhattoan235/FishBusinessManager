# 00_Project_Vision.md

> Phiên bản: 1.0
>
> Cập nhật: 30/07/2026
>
> Trạng thái: Draft
>
> Người thực hiện: Chủ dự án + Solution Architect

---

# Hệ thống quản lý buôn bán chứng nước cho hộ kinh doanh gia đình

## 1. Giới thiệu

Đây là hệ thống quản lý hoạt động buôn bán chứng nước dành riêng cho hộ kinh doanh gia đình.

Khác với các phần mềm bán hàng trên thị trường, hệ thống này được thiết kế dựa trên quy trình làm việc thực tế của gia đình, ưu tiên:

- Đơn giản
- Dễ sử dụng
- Không cần kiến thức công nghệ
- Không cần kiến thức kế toán
- Không cần Internet để hoạt động

Mục tiêu không phải tạo ra phần mềm có nhiều chức năng nhất, mà tạo ra phần mềm mà ba mẹ có thể sử dụng hằng ngày một cách tự nhiên.

---

# 2. Bối cảnh

Hiện tại việc ghi chép chủ yếu thực hiện bằng trí nhớ hoặc sổ tay.

Điều này dẫn đến nhiều vấn đề:

- Khó biết hôm nay lời hay lỗ.
- Khó theo dõi khách còn nợ bao nhiêu.
- Khó kiểm tra hàng còn lại.
- Dễ quên các khoản chi nhỏ.
- Khó thống kê cuối tháng.
- Có nguy cơ mất dữ liệu nếu thất lạc sổ.

Ngoài ra, gia đình có hai nguồn chứng nước:

- Tự sản xuất.
- Mua từ người bán khác.

Điều này khiến việc quản lý càng phức tạp nếu chỉ ghi chép thủ công.

---

# 3. Mục tiêu dự án

Hệ thống phải giúp người dùng trả lời được ngay các câu hỏi sau:

- Hôm nay bán được bao nhiêu tiền?
- Hôm nay chi hết bao nhiêu?
- Hiện còn bao nhiêu tiền?
- Ai còn nợ tiền?
- Người nào nợ nhiều nhất?
- Hàng còn bao nhiêu?
- Hôm nay đã bán những gì?
- Tháng này lời hay lỗ?
- Dữ liệu có được sao lưu an toàn không?

Nếu người dùng mở ứng dụng trong vòng 10 giây thì phải biết được các thông tin quan trọng trên.

---

# 4. Đối tượng sử dụng

## Người dùng chính

Chủ cửa hàng.

Trong thực tế là ba và mẹ cùng sử dụng.

Hai người có quyền giống nhau.

Không phân biệt tài khoản.

---

## Người dùng tương lai

Nếu sau này mở rộng có thể bổ sung:

- Nhân viên bán hàng
- Người quản lý
- Chủ cửa hàng

Tuy nhiên phiên bản đầu tiên chỉ có một vai trò duy nhất:

> Chủ cửa hàng.

---

# 5. Phạm vi dự án

## Bao gồm

- Quản lý khách hàng.
- Quản lý người bán.
- Quản lý sản phẩm.
- Quản lý kho.
- Quản lý bán hàng.
- Quản lý công nợ.
- Ghi nhận thu tiền.
- Ghi nhận chi tiền.
- Báo cáo.
- Sao lưu dữ liệu.
- Khôi phục dữ liệu.

---

## Không bao gồm

Các chức năng dưới đây chưa nằm trong phạm vi phiên bản đầu.

- Hóa đơn điện tử.
- Máy in hóa đơn.
- Quét mã vạch.
- Thanh toán QR.
- Đồng bộ nhiều điện thoại cùng lúc.
- Website quản trị.
- AI phân tích kinh doanh.

Các chức năng này có thể bổ sung trong tương lai.

---

# 6. Triết lý thiết kế

## Nguyên tắc số 1

Ứng dụng phải phục vụ người dùng.

Không bắt người dùng học ứng dụng.

---

## Nguyên tắc số 2

Không bao giờ làm mất dữ liệu.

Đây là nguyên tắc quan trọng nhất.

Mọi thao tác nguy hiểm đều phải có cơ chế bảo vệ.

Ví dụ:

- Tự động sao lưu.
- Khôi phục an toàn.
- Ghi nhật ký hệ thống.

---

## Nguyên tắc số 3

Đơn giản hơn là nhiều chức năng.

Nếu có hai cách thực hiện:

- Một cách nhiều chức năng nhưng khó hiểu.
- Một cách ít chức năng nhưng dễ sử dụng.

Luôn chọn cách thứ hai.

---

## Nguyên tắc số 4

Hoạt động được khi không có Internet.

Toàn bộ nghiệp vụ chính đều phải hoạt động ngoại tuyến.

Internet chỉ dùng cho sao lưu dữ liệu.

---

## Nguyên tắc số 5

Một màn hình chỉ nên giải quyết một công việc.

Ví dụ:

Trang Thu tiền

→ Chỉ để ghi nhận thu tiền.

Không nên hiển thị quá nhiều thông tin khác.

---

# 7. Định hướng giao diện

Ứng dụng hướng đến người lớn tuổi.

Do đó giao diện phải:

- Chữ lớn.
- Màu sắc rõ ràng.
- Ít thao tác.
- Ít màn hình.
- Nút bấm lớn.
- Dễ nhìn dưới ánh sáng ngoài trời.

---

## Ngôn ngữ hiển thị

Không sử dụng thuật ngữ chuyên môn.

Ví dụ

| Không dùng | Thay bằng |
|------------|-----------|
| Dashboard | Trang chủ |
| Transaction | Giao dịch |
| Supplier | Người bán |
| Customer | Người mua |
| Inventory | Hàng còn |
| Cash Balance | Tiền hiện có |
| Backup | Sao lưu |
| Restore | Khôi phục dữ liệu |
| Profit | Tiền lời |

Người dùng không cần hiểu kế toán để sử dụng.

---

# 8. Mục tiêu trải nghiệm

Sau khi mở ứng dụng, trong vòng vài giây người dùng phải nhìn thấy:

- Tiền hiện có.
- Thu hôm nay.
- Chi hôm nay.
- Người còn nợ.
- Hàng còn.

Không cần mở thêm màn hình nào khác.

---

# 9. Định hướng dữ liệu

Toàn bộ dữ liệu lưu trong điện thoại.

Ứng dụng không phụ thuộc Internet.

Internet chỉ dùng để:

- Sao lưu.
- Khôi phục.
- Đồng bộ bản sao lưu.

---

# 10. Định hướng sao lưu

Sao lưu phải diễn ra tự động.

Người dùng không cần nhớ phải sao lưu.

Hệ thống sẽ:

- Tự tạo bản sao lưu định kỳ.
- Tự tải lên Google Drive khi có mạng.
- Giữ nhiều phiên bản sao lưu.
- Kiểm tra tính toàn vẹn trước khi khôi phục.

Mục tiêu cuối cùng là không làm mất dữ liệu.

---

# 11. Tiêu chí thành công

Dự án được xem là thành công khi:

- Ba mẹ có thể sử dụng mà không cần hướng dẫn.
- Không bị mất dữ liệu.
- Thao tác ghi nhận giao dịch dưới 15 giây.
- Có thể sử dụng nhiều năm mà không cần thay đổi cấu trúc dữ liệu.
- Dễ dàng mở rộng khi phát sinh thêm nhu cầu.

---

# 12. Định hướng phát triển

Phiên bản đầu tiên tập trung vào sự ổn định.

Không ưu tiên nhiều chức năng.

Sau khi sử dụng ổn định mới phát triển thêm:

- Đồng bộ nhiều thiết bị.
- Quản lý nhiều cửa hàng.
- Quản lý nhân viên.
- Báo cáo nâng cao.
- AI hỗ trợ thống kê.

---

# 13. Tài liệu liên quan

- 01_Business_Analysis.md
- 02_UseCase_Specification.md
- 03_Business_Rules.md
- 04_UI_UX_Guideline.md
- 05_Backup_And_Recovery.md
- 06_Database_Design.md
- 07_Wireframe_Design.md

---

# 14. Kết luận

Đây không chỉ là ứng dụng ghi thu chi.

Đây là hệ thống quản lý hoạt động buôn bán chứng nước được xây dựng riêng cho mô hình kinh doanh của gia đình.

Mọi quyết định thiết kế đều dựa trên ba tiêu chí:

- Dễ sử dụng.
- An toàn dữ liệu.
- Có thể mở rộng lâu dài.

Trong toàn bộ dự án, trải nghiệm của người dùng luôn được ưu tiên hơn số lượng chức năng.
