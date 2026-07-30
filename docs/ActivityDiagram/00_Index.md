# Activity Diagram — Mục lục (PlantUML)

> Version: 2.0
>
> Last Updated: 30/07/2026
>
> Status: Approved

---

# Danh sách sơ đồ hoạt động (PlantUML)

Thư mục này chứa toàn bộ sơ đồ hoạt động (Activity Diagram) cho các tính năng của ứng dụng Fish Business Manager được viết dưới dạng mã **PlantUML** (`@startuml` ... `@enduml`).

Tất cả các Use Case được ghi rõ tên đầy đủ, không sử dụng ký tự viết tắt hay ký tự đại diện.

---

## Danh sách file sơ đồ hoạt động

| Mã | File | Use Case / Tính năng chính |
|----|------|----------------------------|
| AD-001 | [01_Dashboard.md](./01_Dashboard.md) | UC-001: Xem Trang chủ (Dashboard) |
| AD-002 | [02_Sale.md](./02_Sale.md) | UC-005: Tạo phiếu Bán hàng |
| AD-003 | [03_Income.md](./03_Income.md) | UC-003: Thêm khoản Thu |
| AD-004 | [04_Expense.md](./04_Expense.md) | UC-004: Thêm khoản Chi |
| AD-005 | [05_Debt_Collection.md](./05_Debt_Collection.md) | UC-011: Ghi nhận Thu nợ Khách hàng |
| AD-006 | [06_Inventory_Import.md](./06_Inventory_Import.md) | UC-010A: Nhập kho Hàng hóa (Mua / Thu hoạch) |
| AD-007 | [07_Inventory_Adjustment.md](./07_Inventory_Adjustment.md) | UC-010B: Điều chỉnh Tồn kho |
| AD-008 | [08_Customer_Management.md](./08_Customer_Management.md) | UC-006 & UC-007: Quản lý Khách hàng |
| AD-009 | [09_Supplier_Management.md](./09_Supplier_Management.md) | UC-020: Quản lý Nhà cung cấp (Người bán) |
| AD-010 | [10_Product_Management.md](./10_Product_Management.md) | UC-008 & UC-009: Quản lý Sản phẩm & Đơn vị tính |
| AD-011 | [11_Debt_Overview.md](./11_Debt_Overview.md) | UC-011A: Xem tổng quan Công nợ |
| AD-012 | [12_Transaction_List.md](./12_Transaction_List.md) | UC-002: Xem danh sách Lịch sử Thu chi |
| AD-013 | [13_Backup.md](./13_Backup.md) | UC-012A: Sao lưu dữ liệu (Local & Cloud) |
| AD-014 | [14_Restore.md](./14_Restore.md) | UC-012B: Khôi phục dữ liệu |
| AD-015 | [15_Settings.md](./15_Settings.md) | UC-013: Cài đặt cấu hình ứng dụng |

---

## Hướng dẫn sử dụng PlantUML

- Mã PlantUML nằm trong khối ` ```plantuml ... ``` `.
- Bạn có thể xem trực quan bằng extension **PlantUML** trên VS Code / Antigravity IDE, IntelliJ IDEA, hoặc truy cập [plantuml.com/plantuml](https://www.plantuml.com/plantuml).
