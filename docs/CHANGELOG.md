# CHANGELOG — docs/

## 02/08/2026 — Tồn kho ban đầu và lịch sử khách hàng

- Bổ sung BR-305: khi tạo sản phẩm có thể nhập tồn kho ban đầu, nhưng phải ghi
  qua `inventory_entries` trong cùng Database Transaction.
- Cập nhật Use Case, Screen Specification và Activity Diagram quản lý sản phẩm.
- Làm rõ màn hình chi tiết khách hàng hiển thị cả thanh toán khi mua hàng và các
  lần thu nợ, tách biệt theo đúng khách hàng.
- Khách hàng tạo nhanh trong màn hình Bán hàng được lưu ngay sau bước xác nhận
  tên và số điện thoại; ID vừa tạo được dùng trực tiếp cho phiếu bán.
- Sửa luồng chỉnh sửa để tải đúng khách hàng theo ID, không mở nhầm form thêm mới.
- Khách đã xóa mềm được ẩn khỏi danh sách khách hàng và danh sách chọn khi bán hàng.
- Chi tiết công nợ hiển thị số còn nợ của từng phiếu sau khi phân bổ các lần thu nợ.
- Báo cáo ngày/tháng tự cập nhật khi sổ thu chi thay đổi, tổng hợp theo múi giờ địa
  phương và không bị tràn ở cỡ chữ lớn.

## 30/07/2026 — Dọn dẹp & chốt kiến trúc dữ liệu (v2.0 → v3.0)

### Bối cảnh

Bộ tài liệu trước đó chứa **hai thế hệ thiết kế song song** không được đánh dấu deprecate:

- Bộ "v1": `02_UseCase_Specification.md`, `03_Business_Rules.md`, `04_Application_Flow.md`, `05_UI_UX_Guideline.md`, `06_Wireframe_Design.md`, `07_Architecture_Design.md` (bản cũ), và Chương 1–5 của `10_Database_Design.md` — mô hình **đơn sản phẩm** (chỉ "Chứng nước"), dùng bảng `debts`.
- Bộ "v2": `11_Business_Rules.md`, `12_Use_Cases.md`, `13_UI_UX_Design.md`, `14_Screen_Specification.md`, `15_User_Flow.md`, `16_Flutter_Clean_Architecture.md`, `17_Drift_Database_Implementation.md`, `18_Data_Protection.md`, và Chương 6+ của `10_Database_Design.md` — mô hình **đa sản phẩm** (`products`, `product_categories`, `units`), dùng bảng `customer_balances`.

Ngoài ra, `10_Database_Design.md` tự mâu thuẫn nội bộ: Chương 3 và Chương 6 liệt kê hai danh sách bảng khác nhau (13 bảng vs 15 bảng); Chương 4 và Chương 7–10 lặp lại nguyên văn cùng nội dung. Bản v2 của file này còn dừng lại giữa chừng — chưa bao giờ định nghĩa lại `products`, `sale_items`, `inventory_entries` theo mô hình chuẩn hoá mới.

### Quyết định

Chốt theo **mô hình đa sản phẩm (bộ v2)** làm nguồn chân lý duy nhất cho toàn bộ hệ thống, kể cả phiên bản 1.

### Thay đổi

- **Xóa** (đã bị thay thế hoàn toàn, không giữ song song):
  - `02_UseCase_Specification.md` → thay bằng `03_Use_Cases.md`
  - `03_Business_Rules.md` → thay bằng `02_Business_Rules.md`
  - `04_Application_Flow.md` → thay bằng `07_User_Flow.md`
  - `05_UI_UX_Guideline.md` → thay bằng `05_UI_UX_Design.md`
  - `06_Wireframe_Design.md` → thay bằng `06_Screen_Specification.md`
  - `07_Architecture_Design.md` (bản cũ) → thay bằng `08_Architecture_Design.md` (nội dung từ `16_Flutter_Clean_Architecture.md`, có bổ sung mục Bảo mật Database SQLCipher lấy từ bản cũ)
  - `09_Data_Dictionary.md` + `10_Database_Design.md` → gộp thành `04_Data_Dictionary_and_Database_Design.md`, loại bỏ các chương lặp/lỗi thời, bổ sung các bảng còn thiếu (`products`, cập nhật `sale_items`, `inventory_entries`, `customer_balances`)
- **Đổi số** (nội dung giữ nguyên, chỉ đổi tên file cho liền mạch số thứ tự):
  - `11_Business_Rules.md` → `02_Business_Rules.md`
  - `12_Use_Cases.md` → `03_Use_Cases.md`
  - `13_UI_UX_Design.md` → `05_UI_UX_Design.md`
  - `14_Screen_Specification.md` → `06_Screen_Specification.md`
  - `15_User_Flow.md` → `07_User_Flow.md`
  - `16_Flutter_Clean_Architecture.md` → `08_Architecture_Design.md`
  - `17_Drift_Database_Implementation.md` → `09_Drift_Database_Implementation.md`
  - `18_Data_Protection.md` → `10_Data_Protection.md`
  - `08_Naming_Convention.md` → `11_Naming_Convention.md`
- **Sửa nội dung**:
  - `00_Project_Vision.md` — mục 13 (danh sách tài liệu liên quan) cập nhật đúng tên file mới.
  - `01_Business_Analysis.md` — mục "Sản phẩm" viết lại để phản ánh mô hình đa sản phẩm (danh mục + đơn vị + sản phẩm) ngay từ phiên bản 1, thay vì "chỉ có Chứng nước".
  - `04_Data_Dictionary_and_Database_Design.md` — bổ sung bảng `products` (bị thiếu hoàn toàn ở bản trước), thêm cột `product_id` vào `sale_items` và `inventory_entries` (trước đây thiếu, khiến không thể phân biệt tồn kho theo từng sản phẩm khi có nhiều sản phẩm), đổi tên bảng `debts` → `customer_balances` cho nhất quán với toàn bộ Use Case/Business Rule.
  - `11_Naming_Convention.md` — mục 30 cập nhật danh sách tên tài liệu chuẩn.

### Quy tắc cho tương lai

Khi có thay đổi lớn về nghiệp vụ hoặc kiến trúc dữ liệu:

1. **Không tạo file mới song song** với file đang có (ví dụ không tạo `19_...md` để viết lại nội dung đã có ở `03_...md`).
2. Sửa trực tiếp tài liệu hiện có, hoặc nếu cần viết lại hoàn toàn, phải **xóa bản cũ trong cùng lần commit**.
3. Ghi lại quyết định và lý do vào file `CHANGELOG.md` này.
4. Nếu một quyết định ảnh hưởng nhiều tài liệu (ví dụ đổi tên bảng), phải rà soát và cập nhật **toàn bộ** các tài liệu tham chiếu đến nó trước khi coi là hoàn tất.
