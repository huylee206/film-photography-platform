# Film Photography Creative Space & Analog Lab Platform

Nền tảng kết nối không gian sáng tạo nhiếp ảnh phim (**Darkroom**, **Analog Studio**, **Hybrid Lab**), thuê thiết bị chuyên dụng, vật tư hóa chất và cộng đồng nhiếp ảnh phim — triển khai theo kiến trúc **Service-Oriented Architecture (SOA) & Microservices** đóng gói bằng **Docker**.

## 1. Kiến trúc Microservices & SOA

Hệ thống gồm **8 Docker containers** giao tiếp qua mạng nội bộ `film-soa-net`:

| Thành phần | Công nghệ | Cổng | Nhiệm vụ chính |
| :--- | :--- | :--- | :--- |
| **`api-gateway`** | Nginx 1.27 Alpine | `4000` | Cổng vào duy nhất, Reverse Proxy định tuyến `/api/v1/*`, CORS |
| **`identity-service`** | Node.js + Express + TS | `4001` | Đăng ký/Đăng nhập JWT, Google OAuth2, phân quyền 4 Roles (`FPDP-11`) |
| **`catalog-booking-service`** | Node.js + Express + TS | `4002` | Quản lý Space/Thiết bị/Vật tư, Đặt chỗ chống trùng (`GiST`), QR Check-in, VNPay |
| **`community-service`** | Node.js + Express + TS | `4003` | Cộng đồng phim, bài viết chuyên gia, Workshop, đánh giá & Dashboard |
| **`ai-service`** | Python FastAPI | `8000` | Semantic Search (`pgvector`), Film Recipe RAG, phục chế ảnh, định giá động |
| **`web`** | React 18 + Vite + TS | `5173` | Giao diện web cho Customer, Provider, Expert, Admin |
| **`postgres`** | PostgreSQL 16 + `pgvector` | `5432` | Cô lập dữ liệu theo schema từng service (`identity`, `catalog_booking`, `community`, `ai_vectors`) |
| **`redis`** | Redis 7 Alpine | `6379` | Cache & Event Bus (Pub/Sub) giao tiếp bất đồng bộ giữa các service |

## 2. Khởi chạy nhanh bằng Docker Compose

```bash
cp .env.example .env
docker compose up -d --build
```
* Kiểm tra sức khỏe toàn hệ thống qua API Gateway: `http://localhost:4000/health`
* Truy cập giao diện Web: `http://localhost:5173`

## 3. Lộ trình triển khai (11 Phases)

- [x] **Phase 0** – Khởi động monorepo SOA/Microservices, Docker Compose, CI/CD, Jira Git workflow (`FPDP-8`, `FPDP-9`, `FPDP-10`)
- [x] **Phase 1** – SRS, ERD phân tách schema, Sơ đồ kiến trúc SOA Draw.io, OpenAPI 3.0 Spec
- [ ] **Phase 2** – Xác thực JWT + Google OAuth 2.0 & phân quyền 4 Roles (`FPDP-11` trên `identity-service`)
- [ ] **Phase 3** – Quản lý `CreativeSpace`, `ReusableEquipment`, `ConsumableMaterial` (`catalog-booking-service`)
- [ ] **Phase 4** – Đặt chỗ đa tài nguyên nguyên tử (`GiST`) & thanh toán VNPay (`catalog-booking-service`)
- [ ] **Phase 5** – Check-in QR (`ServiceSession`) & Gói dịch vụ Composite (`ServicePackage`)
- [ ] **Phase 6** – Cộng đồng nhiếp ảnh phim, bài viết chuyên gia & Workshop (`community-service`)
- [ ] **Phase 7** – Dashboard doanh thu Provider & Quản trị Admin (`community-service`)
- [ ] **Phase 8** – Tích hợp 7 tính năng AI (`ai-service` FastAPI + `pgvector`)
- [ ] **Phase 9** – Kiểm thử tải, bảo mật, tối ưu hiệu năng
- [ ] **Phase 10** – Triển khai Production & Bảo vệ đồ án
