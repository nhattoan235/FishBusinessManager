# 11_Business_Rules.md

> Version: 1.0
>
> Status: Approved
>
> Last Updated: 30/07/2026

---

# 1. Giới thiệu

## 1.1 Mục đích

Tài liệu này mô tả toàn bộ quy tắc nghiệp vụ (Business Rules) của ứng dụng quản lý thu chi và bán hàng.

Đây là tài liệu quy định cách hệ thống hoạt động trong từng tình huống thực tế.

Mọi Use Case, Repository và Service trong ứng dụng đều phải tuân theo tài liệu này.

---

## 1.2 Phạm vi

Bao gồm các nghiệp vụ:

- Quản lý khách hàng
- Quản lý nhà cung cấp
- Quản lý sản phẩm
- Bán hàng
- Thu tiền
- Chi tiền
- Công nợ
- Kho
- Sao lưu dữ liệu
- Khôi phục dữ liệu

---

## 1.3 Nguyên tắc

Ứng dụng được xây dựng theo các nguyên tắc:

- Dữ liệu luôn chính xác.
- Không làm mất lịch sử.
- Không chỉnh sửa lịch sử thu chi.
- Không chỉnh sửa lịch sử kho.
- Mọi nghiệp vụ đều có thể kiểm tra lại.

---

# 2. Quy tắc chung

## BR-001 Không xóa dữ liệu lịch sử

Các dữ liệu đã phát sinh giao dịch không được xóa khỏi hệ thống.

Nếu nhập sai:

- Không sửa lịch sử.
- Không xóa lịch sử.
- Tạo bản ghi điều chỉnh.

---

## BR-002 Mọi thay đổi đều có thời gian

Mọi dữ liệu nghiệp vụ phải lưu:

- Ngày tạo
- Ngày cập nhật (nếu có)
- Người tạo (dự phòng mở rộng)

---

## BR-003 Mọi giao dịch đều có ghi chú

Người dùng có thể để trống ghi chú.

Tuy nhiên hệ thống luôn hỗ trợ ghi chú để dễ tra cứu sau này.

Ví dụ:

- Bán cho chú Ba
- Chi mua thức ăn cá
- Thu tiền khách A

---

## BR-004 Không lưu dữ liệu trùng

Một thông tin chỉ nên được lưu tại một nơi.

Ví dụ:

Tên sản phẩm chỉ lưu trong bảng Products.

Sale Item chỉ lưu Product ID.

---

# 3. Quy tắc khách hàng

## BR-101 Tạo khách hàng

Bắt buộc:

- Tên khách hàng

Không bắt buộc:

- Điện thoại
- Địa chỉ
- Ghi chú

---

## BR-102 Sửa khách hàng

Được phép sửa:

- Tên
- Số điện thoại
- Địa chỉ
- Ghi chú

Không ảnh hưởng lịch sử mua bán.

---

## BR-103 Khóa khách hàng

Khách hàng có thể bị khóa.

Khi bị khóa:

- Không xuất hiện trong danh sách chọn mặc định.
- Không được tạo phiếu bán mới.

Lịch sử vẫn được giữ nguyên.

---

## BR-104 Xóa khách hàng

Nếu khách hàng đã phát sinh giao dịch:

Không được xóa.

Chỉ được khóa.

---

# 4. Quy tắc nhà cung cấp

## BR-201

Nhà cung cấp được tạo hoàn toàn thủ công.

---

## BR-202

Không được xóa nếu đã từng nhập hàng.

---

## BR-203

Có thể chỉnh sửa thông tin bất cứ lúc nào.

---

# 5. Quy tắc sản phẩm

## BR-301

Một sản phẩm thuộc đúng một danh mục.

---

## BR-302

Một sản phẩm có một đơn vị tính mặc định.

Ví dụ:

Chứng nước

↓

kg

---

## BR-303

Sản phẩm có thể ngừng kinh doanh.

Khi ngừng kinh doanh:

- Không cho chọn khi bán.
- Không mất lịch sử.

---

## BR-304

Không được xóa sản phẩm đã phát sinh giao dịch.

---

# 6. Quy tắc bán hàng

## BR-401

Một phiếu bán phải có ít nhất một sản phẩm.

---

## BR-402

Không cho phép số lượng bằng 0.

---

## BR-403

Không cho phép đơn giá âm.

---

## BR-404

Sau khi lưu phiếu bán:

Hệ thống phải:

- Ghi chi tiết bán hàng.
- Trừ tồn kho.
- Ghi nhận thu tiền (nếu có).
- Ghi nhận công nợ (nếu còn thiếu).

Toàn bộ phải nằm trong một Transaction của Database.

Nếu có lỗi ở bất kỳ bước nào:

Rollback toàn bộ.

---

## BR-405

Không chỉnh sửa trực tiếp phiếu bán đã hoàn thành.

Nếu phát hiện sai:

- Hủy phiếu (nếu hỗ trợ trong tương lai), hoặc
- Tạo giao dịch điều chỉnh theo quy định.

---

# 7. Quy tắc thu tiền

## BR-501

Mỗi lần thu tiền đều tạo một giao dịch mới.

Không ghi đè lên giao dịch cũ.

---

## BR-502

Một khách hàng có thể trả nhiều lần cho cùng một phiếu bán.

Ví dụ:

Lần 1

200.000đ

↓

Lần 2

300.000đ

↓

Lần 3

500.000đ

Hệ thống phải lưu đầy đủ lịch sử.

---

## BR-503

Không được thu vượt quá số công nợ còn lại.

Nếu người dùng nhập lớn hơn:

Hệ thống phải cảnh báo và không cho lưu.

---

# 8. Quy tắc chi tiền

## BR-601

Mọi khoản chi đều phải có:

- Loại chi
- Số tiền
- Ngày
- Nội dung

---

## BR-602

Các loại chi được quản lý theo danh mục.

Ví dụ:

- Nhập hàng
- Tiền điện
- Tiền nước
- Xăng xe
- Chi khác

---

## BR-603

Không cho phép số tiền nhỏ hơn hoặc bằng 0.

---

# 9. Quy tắc công nợ

## BR-701

Công nợ chỉ phát sinh khi khách chưa thanh toán đủ.

---

## BR-702

Mọi thay đổi công nợ đều phải lưu lịch sử.

Không chỉnh sửa trực tiếp số dư.

---

## BR-703

Số dư công nợ hiện tại chỉ là dữ liệu tổng hợp để tăng tốc hiển thị.

Khi cần, hệ thống có thể tính lại từ lịch sử công nợ.

---

# 10. Quy tắc tồn kho

## BR-801

Kho được quản lý theo Ledger.

Chỉ thêm bản ghi mới.

Không sửa lịch sử.

---

## BR-802

Không cho phép tồn kho âm.

Nếu số lượng bán lớn hơn số lượng còn:

Hệ thống phải cảnh báo.

---

## BR-803

Các nguồn nhập kho gồm:

- Mua từ nhà cung cấp
- Tự sản xuất
- Điều chỉnh kho

---

## BR-804

Mọi thay đổi kho đều phải ghi rõ:

- Loại biến động
- Sản phẩm
- Số lượng
- Thời gian
- Ghi chú (nếu có)

---

# 11. Tổng kết

Tất cả các Use Case của ứng dụng phải tuân thủ các Business Rule trong tài liệu này.

Nếu phát sinh nghiệp vụ mới trong tương lai, phải cập nhật tài liệu trước khi triển khai mã nguồn nhằm đảm bảo tính nhất quán của hệ thống.
