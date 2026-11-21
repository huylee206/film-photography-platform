## 1. Liên kết thẻ Jira (Bắt buộc)
* **Jira Issue**: `FPDP-XXX` *(Ví dụ: FPDP-8, FPDP-11)*

## 2. Microservices / Thành phần chịu tác động
- [ ] `api-gateway` (Nginx routing / CORS)
- [ ] `services/identity-service` (Auth JWT/OAuth2 & RBAC)
- [ ] `services/catalog-booking-service` (Spaces, Equipment, Booking, Payment)
- [ ] `services/community-service` (Posts, Workshops, Reviews, Dashboard)
- [ ] `ai-service` (FastAPI AI features)
- [ ] `web` / `mobile`
- [ ] `infra` / `docs`

## 3. Checklist kiểm tra trước khi Merge
- [ ] Tiêu đề PR có chứa `[FPDP-XXX]`
- [ ] Không commit file `.env` chứa thông tin mật khẩu/secret thật
- [ ] Đã chạy kiểm thử cục bộ hoặc Docker Compose không lỗi
