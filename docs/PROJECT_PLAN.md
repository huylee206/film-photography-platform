# Kế hoạch Dự án Chi tiết (WBS 11 Phases) – FPDP

**Tên dự án:** Nền tảng kết nối cộng đồng nhiếp ảnh phim với dịch vụ phòng tối và phòng chụp (`film-photography-platform`)
**Thời lượng:** 16 tuần (11 Phases từ P0 đến P10)
**Quy ước vai trò:**
- **TL**: Trưởng nhóm / Kiến trúc sư hệ thống
- **BE**: Backend & Database (`@qdat-080106`)
- **FW**: Frontend Web (`@huylee206`)
- **MB**: Mobile App (`@huylee206`)
- **AI**: AI & Research-Based Learning (`@huylee206`, `@qdat-080106`)

---

## 1. Bảng phân rã công việc (WBS) theo Phase

| Phase | Tuần | Mã Task | Tên đầu việc | Phụ trách | Tiêu chí hoàn thành (DoD) |
|---|---|---|---|---|---|
| **P0** | 1 | `P0-01` | Khởi tạo Monorepo, Git Workflow, PR/Issue Templates | TL | Repo chuẩn nhánh `main`/`develop`, CI xanh |
| **P0** | 1 | `P0-02` | Dựng Docker Compose (PostgreSQL+pgvector, Redis, MinIO) | BE | `docker compose up -d` chạy đủ 4 service healthy |
| **P1** | 2 | `P1-01` | Viết đặc tả yêu cầu phần mềm (`docs/requirements/SRS.md`) | TL/BE | Đầy đủ FR, NFR, phân quyền 5 actor |
| **P1** | 2 | `P1-02` | Thiết kế Use Case Diagram & Class Diagram (SOLID + Patterns) | TL | Xuất file `.drawio` chuẩn UML 2.5 |
| **P1** | 3 | `P1-03` | Thiết kế ERD & Migration DDL PostgreSQL (`001_schema.sql`) | BE | Đủ bảng, khóa ngoại, index, ràng buộc `EXCLUDE` |
| **P1** | 3 | `P1-04` | Thiết kế hợp đồng API (`docs/api/openapi.yaml`) | BE/FW | OpenAPI 3.0.3 validate không lỗi |
| **P1** | 3 | `P1-05` | Wireframe Web & Mobile + Design System | FW/MB | Prototype luồng đặt phòng & check-in QR |
| **P1** | 3 | `P1-10` | Khảo sát bài toán RBL & viết đề cương AI (`RBL_PROPOSAL.md`) | AI | Xác định dataset, metric đánh giá 7 tính năng AI |
| **P2** | 4 | `P2-01` | Khởi tạo Backend Modular Architecture, Error Handler, Logger | BE | Server chạy cổng 4000, `/health` trả `200 OK` |
| **P2** | 4 | `P2-02` | Đăng ký, Đăng nhập JWT (Access + Refresh Token) & RBAC | BE | Test unit & integration pass 100% |
| **P2** | 4 | `P2-03` | Đăng nhập Google OAuth 2.0 & xét duyệt `ServiceProviderProfile` | BE | Admin duyệt/từ chối hồ sơ Provider hoạt động |
| **P2** | 4 | `P2-06` | Khởi tạo Web (React + Vite + Tailwind) & Auth Pages | FW | Routing phân quyền theo Role hoạt động |
| **P2** | 4 | `P2-07` | Khởi tạo Mobile (Flutter) & Navigation Shell | MB | App chạy emulator, kết nối API `/health` |
| **P3** | 5-6 | `P3-01` | CRUD `CreativeSpace` (Darkroom/Studio) + Upload ảnh MinIO | BE | Lưu thông số ánh sáng, thông gió, cách âm |
| **P3** | 5-6 | `P3-02` | CRUD `ReusableEquipment` (lịch bảo trì) & `ConsumableMaterial` | BE | Tự động chặn đặt thiết bị đang `MAINTENANCE` |
| **P3** | 6 | `P3-03` | Giao diện tìm kiếm, lọc thông số & chi tiết phòng tối/studio | FW/MB | Bộ lọc đa tiêu chí mượt mà |
| **P4** | 7-9 | `P4-01` | Engine kiểm tra tính khả dụng đa tài nguyên nguyên tử | BE | Transaction cô lập, không race-condition |
| **P4** | 7-9 | `P4-02` | Ràng buộc `EXCLUDE USING gist` chống double-booking | BE | Test 20 request đồng thời chỉ 1 request thành công |
| **P4** | 8-9 | `P4-03` | Tích hợp thanh toán VNPay Sandbox + Webhook IPN | BE/FW | Cập nhật trạng thái `PENDING` -> `CONFIRMED` |
| **P5** | 10-11 | `P5-01` | State Pattern cho `Reservation` & `ServiceSession` (Check-in QR) | BE/MB | Quét QR check-in, thêm vật tư phát sinh khi checkout |
| **P5** | 10-11 | `P5-02` | Composite Pattern cho `ServicePackage` & `PackageItem` | BE/FW | Tính giá gói tự động trừ chiết khấu combo |
| **P6** | 11-12 | `P6-01` | Cộng đồng: `KnowledgeArticle`, Workshop & Đánh giá (`Review`) | BE/FW | Cho phép đánh giá sau khi `COMPLETED` |
| **P7** | 12-13 | `P7-01` | Dashboard doanh thu Provider & Quản trị Admin | FW/BE | Biểu đồ tỷ lệ lấp đầy, doanh thu, cảnh báo tồn kho |
| **P8** | 11-14 | `P8-01` | Dựng FastAPI AI Service + Semantic Search (`pgvector`) | AI | API `/api/v1/ai/semantic-search` hoạt động |
| **P8** | 12-14 | `P8-02` | Gợi ý không gian, RAG trợ lý nhiếp ảnh & Khôi phục ảnh phim | AI/FW | Trả về ảnh khôi phục lưu trên MinIO |
| **P8** | 13-14 | `P8-03` | Dự báo nhu cầu & `DynamicAIPricingStrategy` | AI/BE | Chuyển đổi linh hoạt giữa giá chuẩn và giá động AI |
| **P9** | 14-15 | `P9-01` | Kiểm thử tích hợp E2E, Load Test (k6) & Audit bảo mật | TL/BE | P95 API < 250ms, không lỗ hổng OWASP Top 10 |
| **P10** | 15-16 | `P10-01` | Triển khai Production, hoàn thiện báo cáo & slide bảo vệ | Cả nhóm | Demo live ổn định |

---

## 2. Quản trị rủi ro kỹ thuật

| Rủi ro | Mức độ | Giải pháp giảm thiểu |
|---|---|---|
| Trùng lịch đặt chỗ (Double-booking) khi nhiều người đặt cùng khung giờ | Cao | Kết hợp `SELECT FOR UPDATE` trong transaction và ràng buộc `EXCLUDE USING gist` dưới PostgreSQL |
| Sai lệch tồn kho vật tư tiêu hao (`ConsumableMaterial`) | Trung bình | Trừ kho nguyên tử theo `allocated_qty`, kích hoạt `InventoryAlertService` qua Observer Pattern |
| Dịch vụ AI phản hồi chậm gây nghẽn Backend | Trung bình | Tách microservice FastAPI độc lập qua `AIServicePort`, đặt timeout & fallback về `StandardPricingStrategy` |
