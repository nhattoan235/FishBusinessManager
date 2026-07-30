# 03_Business_Rules.md

> Version: 1.0
>
> Last Updated: 30/07/2026
>
> Status: Draft

---

# 1. Giới thiệu

Tài liệu này định nghĩa toàn bộ quy tắc nghiệp vụ (Business Rules) của hệ thống.

Business Rule là những quy định mà hệ thống bắt buộc phải tuân thủ.

Mọi chức năng, giao diện, cơ sở dữ liệu và chương trình đều phải dựa trên các quy tắc này.

Nếu có thay đổi Business Rule thì phải cập nhật tài liệu trước khi sửa chương trình.

---

# 2. Quy ước đặt mã

| Nhóm | Mã |
|------|------|
| Quy tắc chung | BR100 |
| Người mua | BR200 |
| Người bán | BR300 |
| Loại hàng | BR400 |
| Kho | BR500 |
| Bán hàng | BR600 |
| Giao dịch | BR700 |
| Công nợ | BR800 |
| Sao lưu | BR900 |
| Nhật ký hệ thống | BR1000 |
| Giao diện | UX100 |

---

# BR100 - Quy tắc chung

---

## BR101

Tên

Ứng dụng phải hoạt động khi không có Internet.

Mô tả

Toàn bộ chức năng chính phải sử dụng được ngoại tuyến.

Internet chỉ phục vụ:

- Sao lưu
- Khôi phục
- Đồng bộ bản sao lưu

---

## BR102

Chỉ có một vai trò sử dụng.

Tên vai trò:

Chủ cửa hàng.

Không phân quyền trong phiên bản đầu.

---

## BR103

Mọi dữ liệu đều lưu cục bộ trước.

Sau đó mới thực hiện sao lưu.

---

## BR104

Không cho phép dữ liệu bị mất sau khi lưu thành công.

---

# BR200 - Người mua

---

## BR201

Tên người mua là bắt buộc.

---

## BR202

Số điện thoại không bắt buộc.

---

## BR203

Địa chỉ không bắt buộc.

---

## BR204

Không được xóa người mua nếu đã phát sinh giao dịch.

Giải pháp

Đánh dấu:

Ngừng giao dịch.

---

# BR300 - Người bán

---

## BR301

Người bán không sử dụng ứng dụng.

---

## BR302

Toàn bộ thông tin người bán được nhập thủ công.

---

## BR303

Không cho xóa người bán đã từng nhập hàng.

---

# BR400 - Loại hàng

---

## BR401

Phiên bản đầu mặc định chỉ có:

Chứng nước.

---

## BR402

Không hiển thị mục "Loại hàng" trên màn hình bán nếu chỉ có một loại.

---

## BR403

Hệ thống vẫn phải thiết kế để hỗ trợ nhiều loại hàng trong tương lai.

---

# BR500 - Kho

---

## BR501

Kho không được âm.

---

## BR502

Không cho phép bán vượt số lượng hàng còn.

Thông báo

"Hàng còn không đủ."

---

## BR503

Có hai nguồn nhập kho.

- Mua từ người bán
- Thu hoạch

---

## BR504

Mỗi lần nhập kho phải ghi rõ nguồn.

---

## BR505

Giảm kho ngay sau khi bán thành công.

---

# BR600 - Bán hàng

---

## BR601

Một đơn bán chỉ thuộc một người mua.

---

## BR602

Một đơn bán chỉ lưu sau khi hợp lệ.

---

## BR603

Nếu khách trả thiếu

↓

Tự sinh công nợ.

---

## BR604

Nếu khách trả đủ

↓

Không sinh công nợ.

---

## BR605

Không cho phép khách trả nhiều hơn tổng tiền.

---

## BR606

Không cho phép bán khi kho không đủ.

---

## BR607

Mọi đơn bán đều sinh lịch sử giao dịch.

---

## BR608

Không được xóa đơn bán.

Nếu cần

↓

Đưa vào Thùng rác.

---

# BR700 - Giao dịch

---

## BR701

Giao dịch chỉ có hai loại.

- Thu
- Chi

---

## BR702

Một giao dịch không được vừa Thu vừa Chi.

---

## BR703

Số tiền phải lớn hơn 0.

---

## BR704

Ngày giao dịch mặc định là ngày hiện tại.

Người dùng có thể thay đổi.

---

## BR705

Giờ giao dịch mặc định là giờ hiện tại.

Người dùng có thể thay đổi.

---

## BR706

Nội dung giao dịch là bắt buộc.

Ví dụ

- Bán chứng nước
- Mua cám
- Đổ xăng
- Thu nợ

---

## BR707

Sau khi lưu

Tiền hiện có phải cập nhật ngay.

---

## BR708

Cho phép sửa giao dịch.

---

## BR709

Không xóa vĩnh viễn giao dịch.

↓

Đưa vào Thùng rác.

---

## BR710

Mọi thay đổi giao dịch đều lưu nhật ký.

---

# BR800 - Công nợ

---

## BR801

Chỉ phát sinh khi khách trả thiếu.

---

## BR802

Không được thu nợ vượt quá số tiền còn thiếu.

---

## BR803

Thu nợ luôn tạo giao dịch Thu.

---

## BR804

Công nợ bằng 0

↓

Đánh dấu

Đã thanh toán.

---

# BR900 - Sao lưu

---

## BR901

Sao lưu được thực hiện tự động.

---

## BR902

Người dùng vẫn có thể chọn

"Sao lưu ngay"

nếu muốn.

---

## BR903

Mỗi lần sao lưu tạo một phiên bản mới.

Không ghi đè.

---

## BR904

Bản sao lưu phải lưu tại:

- Điện thoại
- Google Drive (khi có Internet)

---

## BR905

Nếu không có Internet

↓

Đưa vào hàng chờ.

Khi có Internet

↓

Tự tải lên.

---

## BR906

Khôi phục dữ liệu luôn thực hiện:

1. Kiểm tra file
2. Sao lưu dữ liệu hiện tại
3. Khôi phục

---

## BR907

Nếu khôi phục thất bại

↓

Giữ nguyên dữ liệu hiện tại.

---

## BR908

Áp dụng Retention Policy.

Giữ:

- 7 bản gần nhất theo ngày
- 4 bản theo tuần
- 12 bản theo tháng
- 5 bản theo năm

---

# BR1000 - Nhật ký hệ thống

---

## BR1001

Mọi thao tác sau phải lưu nhật ký.

- Thêm
- Sửa
- Xóa
- Khôi phục
- Sao lưu

---

## BR1002

Nhật ký không được sửa.

---

## BR1003

Nhật ký chỉ được xem.

Không được xóa.

---

# UX100 - Quy tắc giao diện

---

## UX101

Không sử dụng thuật ngữ chuyên môn.

Ví dụ

Dashboard

↓

Trang chủ

---

## UX102

Tiền luôn căn phải.

---

## UX103

Thu

↓

Màu xanh.

---

## UX104

Chi

↓

Màu đỏ.

---

## UX105

Chữ lớn.

Tối thiểu

18sp.

---

## UX106

Nút chính

Tối thiểu

56dp.

---

## UX107

Hiển thị ngày

dd/MM/yyyy

Ví dụ

30/07/2026

---

## UX108

Hiển thị giờ

HH:mm

Ví dụ

09:35

---

## UX109

Tiền luôn có dấu phân cách.

Ví dụ

15.300.000đ

---

## UX110

Không dùng bảng dữ liệu.

Hiển thị dạng danh sách hoặc Timeline.

---

## UX111

Trang chủ luôn hiển thị:

- Tiền hiện có
- Thu hôm nay
- Chi hôm nay
- Giao dịch gần nhất

---

## UX112

Mọi thông báo lỗi đều sử dụng ngôn ngữ đời thường.

Ví dụ

"Hàng còn không đủ."

Không dùng

"Inventory validation failed."

---

# 3. Kết luận

Business Rules là nền tảng để:

- Thiết kế Database.
- Thiết kế API.
- Thiết kế giao diện.
- Viết Unit Test.
- Viết Integration Test.
- Kiểm thử nghiệp vụ.

Mọi chức năng của hệ thống phải tuân thủ đúng các Business Rule được định nghĩa trong tài liệu này.

Không được tự ý thay đổi Business Rule trong quá trình lập trình nếu chưa cập nhật tài liệu.
