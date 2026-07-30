# 05_UI_UX_Guideline.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Draft

---

# 1. Mục tiêu

Tài liệu này định nghĩa toàn bộ tiêu chuẩn giao diện của ứng dụng.

Mục tiêu lớn nhất:

> Ba mẹ có thể sử dụng ứng dụng ngay mà không cần hướng dẫn.

Ứng dụng ưu tiên:

- Dễ nhìn
- Dễ hiểu
- Dễ thao tác
- Ít bấm
- Ít suy nghĩ

Không chạy theo giao diện hiện đại quá mức nếu làm giảm khả năng sử dụng.

---

# 2. Đối tượng sử dụng

Độ tuổi

50+

Đặc điểm

- Không rành công nghệ
- Thị lực giảm
- Thao tác chậm
- Không quen thuật ngữ chuyên môn

Do đó giao diện phải:

- Chữ lớn
- Khoảng cách rộng
- Nút to
- Màu sắc rõ ràng
- Thông báo dễ hiểu

---

# 3. Triết lý thiết kế

## UX001

Một màn hình chỉ giải quyết một công việc.

Ví dụ

Trang Bán hàng

↓

Chỉ để bán hàng.

Không đặt thêm thống kê.

---

## UX002

Ít thao tác nhất có thể.

Nếu có hai cách:

- 5 lần bấm
- 2 lần bấm

Luôn chọn 2 lần bấm.

---

## UX003

Không yêu cầu người dùng nhớ.

Hệ thống phải ghi nhớ thay.

Ví dụ

- Ngày hiện tại
- Giờ hiện tại
- Người mua gần nhất
- Giá bán gần nhất

---

## UX004

Mọi thao tác đều có phản hồi.

Ví dụ

Đã lưu thành công.

Đang sao lưu...

Đang tải...

Không có dữ liệu.

---

# 4. Thiết kế màu sắc

## Màu nền

FFFFFF

Trắng.

---

## Màu chính

2E7D32

Xanh lá.

Ý nghĩa

An toàn.

Tin cậy.

---

## Thu

16A34A

Xanh.

---

## Chi

DC2626

Đỏ.

---

## Cảnh báo

F59E0B

Cam.

---

## Lỗi

B91C1C

Đỏ đậm.

---

## Thông tin

2563EB

Xanh dương.

---

## Divider

E5E7EB

Xám nhạt.

---

## Card

F8FAFC

---

# 5. Typography

Font

Noto Sans

---

Tiêu đề lớn

28sp

Bold

---

Tiêu đề

22sp

Bold

---

Tiêu đề nhỏ

20sp

SemiBold

---

Nội dung

18sp

Regular

---

Chú thích

16sp

Regular

---

Không sử dụng font nghệ thuật.

---

# 6. Icon

Ưu tiên

Material Icons.

Không sử dụng icon khó hiểu.

Ví dụ

💰

Thu.

💸

Chi.

🛒

Bán hàng.

👤

Người mua.

🏪

Người bán.

📦

Kho.

📊

Báo cáo.

☁️

Sao lưu.

⚙️

Cài đặt.

---

# 7. Kích thước

Nút chính

Chiều cao

56dp

---

Nút phụ

48dp

---

Bo góc

16dp

---

Card

20dp

---

Padding

16dp

---

Khoảng cách giữa các Card

16dp

---

# 8. Trang chủ

Luôn hiển thị

Tiền hiện có

↓

Lớn nhất màn hình.

---

Bên dưới

3 nút lớn

- Bán hàng
- Thu
- Chi

---

Tiếp theo

Thông tin hôm nay

- Thu hôm nay
- Chi hôm nay

---

Cuối cùng

10 giao dịch gần nhất.

---

# 9. Màn hình giao dịch

Các trường

Loại

↓

Thu

Chi

---

Số tiền

↓

Font lớn.

---

Ngày

↓

Mặc định hôm nay.

---

Giờ

↓

Mặc định hiện tại.

---

Nội dung

↓

Bắt buộc.

---

Nút

Lưu

↓

Chiếm toàn chiều ngang.

---

# 10. Danh sách giao dịch

Hiển thị dạng Card.

Không dùng bảng.

Ví dụ

09:30

🟢 Thu

300.000đ

Bán chứng nước

-------------------

10:15

🔴 Chi

150.000đ

Đổ xăng

---

Cho phép

- Tìm kiếm
- Lọc
- Sắp xếp

---

# 11. Quy tắc hiển thị tiền

Luôn có dấu phân cách.

Ví dụ

15.300.000đ

Không hiển thị

15300000

---

Tiền luôn căn phải.

---

Không hiển thị số âm bằng màu đen.

Nếu âm

↓

Đỏ.

---

# 12. Quy tắc ngày giờ

Ngày

dd/MM/yyyy

Ví dụ

30/07/2026

---

Giờ

HH:mm

09:30

---

Không dùng định dạng ISO trên giao diện.

---

# 13. Thông báo

Đúng

"Hàng còn không đủ."

Sai

"Inventory Error"

---

Đúng

"Đã lưu thành công."

Sai

"Insert completed"

---

Đúng

"Không tìm thấy dữ liệu."

Sai

"404"

---

# 14. Hiệu ứng

Animation

Ngắn.

≤200ms.

---

Không dùng animation phức tạp.

---

Không dùng hiệu ứng gây rối mắt.

---

# 15. Trạng thái màn hình

Loading

↓

Skeleton.

---

Empty

↓

Minh họa đơn giản.

"Chưa có dữ liệu."

---

Success

↓

Snackbar.

---

Error

↓

Dialog.

---

# 16. Accessibility

Hỗ trợ

Chữ lớn.

---

Độ tương phản đạt chuẩn.

---

Không phân biệt trạng thái chỉ bằng màu.

Ví dụ

Thu

↓

🟢 + chữ "Thu"

Chi

↓

🔴 + chữ "Chi"

---

Nút bấm tối thiểu

56dp.

---

# 17. Quy tắc điều hướng

Không quá

3 lần chạm

để tới chức năng chính.

---

Không có màn hình cụt.

---

Luôn có nút quay lại.

---

# 18. Không sử dụng

Không Popup quảng cáo.

Không Splash quá 2 giây.

Không hiệu ứng rung liên tục.

Không âm thanh khi bấm.

Không yêu cầu Internet.

Không đăng nhập.

---

# 19. Tiêu chuẩn chất lượng

Người mới sử dụng phải hoàn thành:

Ghi giao dịch Thu

<15 giây.

---

Bán hàng

<20 giây.

---

Thu nợ

<15 giây.

---

Sao lưu

1 lần bấm.

---

# 20. Kết luận

Toàn bộ giao diện của ứng dụng phải tuân thủ tài liệu này.

Không bổ sung hiệu ứng hoặc thay đổi màu sắc nếu chưa đánh giá ảnh hưởng đến trải nghiệm của người dùng.
# 20. Design System

Toàn bộ ứng dụng sử dụng một hệ thống Component thống nhất.

Không tự ý tạo Component mới nếu đã tồn tại Component tương đương.

---

## DS001 - Primary Button

Mục đích

Thực hiện hành động chính.

Ví dụ

- Lưu
- Xác nhận
- Bán hàng

Thuộc tính

- Chiều cao: 56dp
- Bo góc: 16dp
- Font: 18sp Bold
- Màu nền: Primary Green
- Chữ màu trắng

Chỉ sử dụng một Primary Button trên mỗi màn hình.

---

## DS002 - Secondary Button

Mục đích

Thực hiện hành động phụ.

Ví dụ

- Hủy
- Quay lại

Thuộc tính

- Nền trắng
- Viền xanh
- Chữ xanh

---

## DS003 - Danger Button

Chỉ dùng cho

- Xóa
- Khôi phục dữ liệu
- Đặt lại dữ liệu

Màu

Đỏ.

Luôn yêu cầu xác nhận trước khi thực hiện.

---

## DS004 - Money Card

Hiển thị

- Tiền hiện có
- Thu hôm nay
- Chi hôm nay

Thuộc tính

- Card lớn
- Bo góc 20dp
- Có icon
- Font tiền 30sp Bold

Ví dụ

┌────────────────────┐

Tiền hiện có

15.300.000đ

└────────────────────┘

---

## DS005 - Summary Card

Hiển thị

Thông tin thống kê.

Ví dụ

- Hàng còn
- Khách đang nợ
- Tổng thu

---

## DS006 - Transaction Card

Một giao dịch luôn hiển thị dạng Card.

Bao gồm

- Icon
- Loại
- Số tiền
- Ngày
- Giờ
- Nội dung

Không dùng Table.

---

## DS007 - Input Field

Chiều cao

56dp

Có Label.

Có Placeholder.

Có Icon nếu cần.

---

## DS008 - Search Box

Luôn nằm đầu danh sách.

Có icon tìm kiếm.

Có nút xóa nhanh.

---

## DS009 - Bottom Sheet

Dùng cho

- Chọn ngày
- Chọn người mua
- Chọn người bán

Không dùng Dialog nếu có nhiều lựa chọn.

---

## DS010 - Confirmation Dialog

Dùng khi

- Xóa
- Khôi phục
- Thoát

Luôn có

- Đồng ý
- Hủy

---

## DS011 - Snackbar

Hiển thị

- Đã lưu
- Đã sao lưu
- Thành công

Tự đóng sau

2 giây.

---

## DS012 - Badge

Dùng cho

- Khách còn nợ
- Sao lưu thất bại
- Đồng bộ chờ

Không lạm dụng Badge.

---

# 21. Responsive Design Rules

Ứng dụng ưu tiên điện thoại.

Tablet là tùy chọn trong tương lai.

---

## RD001

Không khóa kích thước màn hình.

---

## RD002

Layout sử dụng Responsive.

Không dùng kích thước cố định.

---

## RD003

Điện thoại nhỏ (<6")

Hiển thị

1 cột.

---

## RD004

Điện thoại lớn

Card giãn theo chiều ngang.

---

## RD005

Tablet

Có thể chia

2 cột.

---

## RD006

Danh sách giao dịch

Luôn cuộn dọc.

---

## RD007

Card

Chiều rộng

100%.

---

## RD008

Khoảng cách

Sử dụng hệ thống 8dp.

Ví dụ

8

16

24

32

Không sử dụng khoảng cách ngẫu nhiên.

---

## RD009

Tiêu đề không xuống dòng quá 2 dòng.

---

## RD010

Font không nhỏ hơn

16sp.

---

# 22. Motion Guideline

Mục tiêu

Hiệu ứng phải hỗ trợ người dùng.

Không làm người dùng mất tập trung.

---

## MG001

Mở màn hình

Hiệu ứng

Fade + Slide.

Thời gian

150ms.

---

## MG002

Đóng màn hình

Slide Right.

150ms.

---

## MG003

Mở Dialog

Scale nhẹ.

100ms.

---

## MG004

Snackbar

Slide Up.

200ms.

---

## MG005

Loading

Circular Progress.

Không dùng animation phức tạp.

---

## MG006

Lưu thành công

Hiển thị Snackbar.

Không chuyển màn hình đột ngột.

---

## MG007

Danh sách

Xuất hiện bằng Fade.

---

## MG008

Card

Có hiệu ứng Ripple khi bấm.

---

## MG009

Không sử dụng

- Animation xoay
- Animation nhấp nháy
- Animation liên tục
- Hiệu ứng gây chóng mặt

---

## MG010

Toàn bộ Animation

≤200ms.

Ưu tiên

150ms.

---

# 23. Nguyên tắc nhất quán

Toàn bộ ứng dụng phải tuân theo các nguyên tắc sau.

- Cùng một chức năng luôn có cùng vị trí.
- Cùng một màu luôn biểu thị cùng một ý nghĩa.
- Cùng một biểu tượng luôn có cùng chức năng.
- Cùng một thao tác luôn có cùng phản hồi.
- Không thay đổi giao diện giữa các màn hình nếu không cần thiết.

---

# 24. Kết luận

UI/UX không chỉ là yếu tố thẩm mỹ mà còn là nền tảng giúp người dùng thao tác nhanh, chính xác và ít sai sót.

Mọi thay đổi về giao diện, màu sắc, component hoặc hiệu ứng đều phải tuân thủ tài liệu này để đảm bảo tính nhất quán trong toàn bộ hệ thống.
