# film-photography-platform (FPDP)

Nền tảng kết nối cộng đồng nhiếp ảnh phim với các dịch vụ phòng tối (Darkroom) và phòng chụp (Studio).
*(Platform Connecting the Film Photography Community with Darkroom and Studio Services)*

## 1. Giới thiệu hệ thống

Hệ thống đa phía (Multi-Sided Platform) hỗ trợ 5 nhóm tác nhân chính:

- **Photographer (Nhiếp ảnh gia)**: tìm kiếm, so sánh thông số kỹ thuật (ánh sáng, thông gió, cách âm), đặt phòng tối/studio + thiết bị + vật tư, check-in QR, thanh toán, đánh giá và tham gia cộng đồng.
- **Service Provider (Nhà cung cấp dịch vụ)**: đăng ký kinh doanh, quản lý không gian sáng tạo, thiết bị tái sử dụng (kèm lịch bảo trì), vật tư tiêu hao (cảnh báo tồn kho thấp), tạo gói dịch vụ combo, theo dõi doanh thu.
- **Photography Expert (Chuyên gia nhiếp ảnh)**: xuất bản bài viết kiến thức kỹ thuật tráng/rọi phim (lập chỉ mục vector ngữ nghĩa), tổ chức workshop, đánh giá thiết bị.
- **Administrator (Quản trị viên)**: xét duyệt hồ sơ Service Provider, giám sát giao dịch, điều phối tranh chấp và kiểm duyệt nội dung.
- **AI Assistant (Dịch vụ trí tuệ nhân tạo)**: gợi ý không gian/thiết bị cá nhân hóa, tìm kiếm ngữ nghĩa (`pgvector`), trợ lý RAG nhiếp ảnh, khôi phục ảnh phim cũ, dự báo nhu cầu và định giá động.

## 2. Kiến trúc & Cấu trúc Monorepo

```text
film-photography-platform/
├── backend/              # REST API (TypeScript, Express, Modular SOLID Architecture)
├── web/                  # Web App (React 18, Vite, TypeScript, TailwindCSS)
├── mobile/               # Mobile App cho Photographer (Flutter / Dart)
├── ai/                   # AI Service (Python 3.11, FastAPI, Pydantic, Pytest)
├── infra/                # Hạ tầng & Database DDL/Seed (PostgreSQL + pgvector, Redis, MinIO)
├── docs/                 # SRS, ERD, Kiến trúc, OpenAPI 3.0, Sơ đồ Draw.io, Kế hoạch WBS, RBL
├── .github/              # GitHub Actions CI, CODEOWNERS, PR & Issue Templates
├── docker-compose.yml    # Orchestration PostgreSQL (pgvector), Redis, MinIO + Bucket Init
├── GIT_WORKFLOW.md       # Quy ước nhánh, Conventional Commits, quy trình PR
├── .env.example          # Mẫu biến môi trường
└── README.md
```

## 3. Khởi chạy nhanh (Quick Start)

### Bước 1: Khởi chạy hạ tầng (PostgreSQL + pgvector, Redis, MinIO)
```bash
cp .env.example .env
docker compose up -d
docker compose ps
```

| Dịch vụ | Địa chỉ | Ghi chú |
|---|---|---|
| PostgreSQL 16 (`pgvector` + `btree_gist`) | `localhost:5432` | Tự động chạy `00_init.sql`, `01_schema.sql`, `02_seed.sql` |
| Redis 7 | `localhost:6379` | Cache & khóa phân tán |
| MinIO API | `http://localhost:9000` | Tự động tạo bucket `film-media`, `film-restored` |
| MinIO Console | `http://localhost:9001` | Tài khoản mặc định trong `.env.example` |

### Bước 2: Chạy từng phân hệ phát triển
- **Backend API**: `cd backend && npm install && npm run dev` (Port `4000`)
- **Web Frontend**: `cd web && npm install && npm run dev` (Port `5173`)
- **AI Service**: `cd ai && pip install -r requirements.txt && uvicorn app.main:app --reload --port 8000`
- **Mobile App**: `cd mobile && flutter pub get && flutter run`

## 4. Tài liệu & Quy trình nhóm

- Quy ước Git & Pull Request: [`GIT_WORKFLOW.md`](GIT_WORKFLOW.md)
- Kế hoạch chi tiết 11 Phase (WBS): [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md)
- Đặc tả yêu cầu phần mềm (SRS): [`docs/requirements/SRS.md`](docs/requirements/SRS.md)
- Kiến trúc hệ thống & ERD: [`docs/design/ARCHITECTURE.md`](docs/design/ARCHITECTURE.md)
- Hợp đồng API (OpenAPI 3.0): [`docs/api/openapi.yaml`](docs/api/openapi.yaml)
- Đề cương nghiên cứu AI (RBL): [`docs/research/RBL_PROPOSAL.md`](docs/research/RBL_PROPOSAL.md)

## 5. Thành viên dự án

| Họ và tên | GitHub |
|---|---|---|
| Nguyễn Quốc Đạt | `@qdat-080106` | 
| Lê Gia Huy | `@huylee206` |

## 6. Lộ trình triển khai (11 Phases)

- [x] **Phase 0** – Khởi động repo, Docker infra, CI/CD, Git workflow
- [x] **Phase 1** – SRS, ERD, Class Diagram, Use Case Diagram, OpenAPI 3.0 Spec
- [ ] **Phase 2** – Xác thực JWT + Google OAuth 2.0 & phân quyền RBAC
- [ ] **Phase 3** – Quản lý CreativeSpace, ReusableEquipment, ConsumableMaterial
- [ ] **Phase 4** – Đặt chỗ đa tài nguyên nguyên tử (Anti double-booking) & thanh toán VNPay
- [ ] **Phase 5** – Check-in QR (`ServiceSession`) & Gói dịch vụ Composite (`ServicePackage`)
- [ ] **Phase 6** – Cộng đồng nhiếp ảnh phim, bài viết chuyên gia & Workshop
- [ ] **Phase 7** – Dashboard doanh thu Provider & Quản trị Admin
- [ ] **Phase 8** – Tích hợp 7 tính năng AI (Semantic Search, RAG, Restoration, Dynamic Pricing)
- [ ] **Phase 9** – Kiểm thử tải, bảo mật, tối ưu hiệu năng
- [ ] **Phase 10** – Triển khai Production & Bảo vệ đồ án
