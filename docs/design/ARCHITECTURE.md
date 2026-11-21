# Kiến trúc Hệ thống — Service-Oriented Architecture (SOA) & Microservices

## 1. Tổng quan Kiến trúc (Architecture Overview)
Hệ thống **Film Photography Creative Space & Analog Lab Platform** được thiết kế và triển khai theo chuẩn **Service-Oriented Architecture (SOA)** kết hợp **Microservices** và đóng gói hoàn toàn bằng **Docker**:

1. **API Gateway (`api-gateway` - Nginx, Port `4000`)**:
   * Điểm truy cập duy nhất (Single Entry Point) cho cả ứng dụng Web (`React/Vite`) và Mobile (`Flutter`).
   * Đảm nhiệm định tuyến ngược (Reverse Proxy) theo từng miền nghiệp vụ `/api/v1/*`, xử lý CORS, chèn header truy vết SOA (`X-Gateway-Version`, `X-Forwarded-For`) và cân bằng tải.
2. **4 Microservices Độc Lập (Independent Domain Services)**:
   * **`identity-service` (Node.js/TypeScript, Port `4001`)**: Quản lý định danh, đăng ký/đăng nhập JWT, Google OAuth 2.0, phân quyền 4 vai trò (`CUSTOMER`, `PROVIDER`, `EXPERT`, `ADMIN`) và cung cấp hợp đồng dịch vụ nội bộ (`POST /internal/verify-token`) cho các service khác.
   * **`catalog-booking-service` (Node.js/TypeScript, Port `4002`)**: Quản lý không gian sáng tạo (`CreativeSpace`), thiết bị tái sử dụng (`ReusableEquipment`), vật tư tiêu hao (`ConsumableMaterial`), đặt chỗ nguyên tử chống trùng lịch bằng `PostgreSQL GiST`, phiên sử dụng QR (`ServiceSession`) và thanh toán `VNPay`.
   * **`community-service` (Node.js/TypeScript, Port `4003`)**: Quản lý cộng đồng nhiếp ảnh phim, bài viết chuyên gia, workshop, đánh giá sau buổi chụp và thống kê doanh thu.
   * **`ai-service` (Python FastAPI, Port `8000`)**: Dịch vụ trí tuệ nhân tạo chuyên biệt cung cấp 7 tính năng: Semantic Search (`pgvector`), Film Recipe RAG, phục chế ảnh âm bản, định giá động, kiểm tra tương thích thiết bị, chẩn đoán lỗi tráng phim và dự báo nhu cầu.
3. **Phân tách Dữ liệu theo Dịch vụ (Database-per-Service / Schema Isolation)**:
   * Mỗi microservice sở hữu schema dữ liệu riêng biệt trên PostgreSQL 16 (`identity.*`, `catalog_booking.*`, `community.*`, `ai_vectors.*`), tuyệt đối không truy vấn chéo bảng trực tiếp giữa các service mà giao tiếp qua REST API hợp đồng chuẩn hoặc Event Bus bất đồng bộ qua **Redis Pub/Sub**.

## 2. Bảng định tuyến dịch vụ qua API Gateway (`:4000`)

| Prefix Đường dẫn | Microservice Đích | Container & Cổng nội bộ | Schema Dữ liệu |
| :--- | :--- | :--- | :--- |
| `/api/v1/auth/*`, `/api/v1/users/*` | **Identity Service** | `identity-service:4001` | `identity` |
| `/api/v1/spaces/*`, `/api/v1/resources/*` | **Catalog & Booking Service** | `catalog-booking-service:4002` | `catalog_booking` |
| `/api/v1/bookings/*`, `/api/v1/packages/*` | **Catalog & Booking Service** | `catalog-booking-service:4002` | `catalog_booking` |
| `/api/v1/sessions/*`, `/api/v1/payments/*` | **Catalog & Booking Service** | `catalog-booking-service:4002` | `catalog_booking` |
| `/api/v1/community/*`, `/api/v1/workshops/*` | **Community Service** | `community-service:4003` | `community` |
| `/api/v1/reviews/*`, `/api/v1/dashboard/*` | **Community Service** | `community-service:4003` | `community` |
| `/api/v1/ai/*` | **AI Microservice** | `ai-service:8000` | `ai_vectors` |

## 3. Giao tiếp Liên dịch vụ (SOA Service Contracts & Event-Driven)
* **Synchronous Service-to-Service (REST/JSON)**: Khi `catalog-booking-service` cần xác thực danh tính hoặc quyền truy cập, dịch vụ gọi hợp đồng nội bộ `POST http://identity-service:4001/internal/verify-token` qua mạng nội bộ Docker `film-soa-net`.
* **Asynchronous Event Bus (Redis Pub/Sub)**: Khi thanh toán thành công (`PAYMENT_SUCCEEDED`), `catalog-booking-service` phát sự kiện lên kênh Redis `booking.confirmed` để `community-service` tạo thông báo tự động và `ai-service` cập nhật dữ liệu dự báo nhu cầu.
