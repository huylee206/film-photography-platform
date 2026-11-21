# Quy trình Git & Tích hợp Jira (`FPDP-*`)

Tài liệu này quy định chuẩn làm việc nhóm trên GitHub và đồng bộ tự động với **Jira (`GitHub for Atlassian`)** cho dự án **Film Photography Platform**.

## 1. Chiến lược nhánh (Branching Model)
* **`main`**: Nhánh Production ổn định, chỉ nhận merge từ `develop` qua Pull Request đã duyệt.
* **`develop`**: Nhánh tích hợp chính của nhóm. Mọi nhánh tính năng đều tách từ `develop` và merge ngược lại vào `develop`.
* **Nhánh công việc (Feature/Fix/Chore Branches)**: Bắt buộc chứa mã thẻ Jira **`FPDP-<số>`**:
  * `feat/FPDP-11-auth-jwt-oauth2-rbac`
  * `fix/FPDP-24-booking-gist-overlap`
  * `chore/FPDP-8-microservices-architecture`
  * `docs/FPDP-9-soa-openapi-spec`

## 2. Quy chuẩn Commit Message (Conventional Commits + Jira)
Cài đặt template commit cho local repo:
```bash
git config commit.template .gitmessage
```

Cấu trúc commit bắt buộc:
```text
<type>(<scope>): <mô tả ngắn gọn không dấu chấm cuối>

Refs: FPDP-<mã_task>
```
* **`type` hợp lệ**: `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci`, `chore`.
* **`scope` hợp lệ**: `gateway`, `identity`, `catalog`, `booking`, `payment`, `community`, `ai`, `web`, `mobile`, `db`, `infra`.
* **Ví dụ chuẩn**:
  ```text
  feat(identity): implement jwt login and 4-role rbac middleware

  Refs: FPDP-11
  ```

## 3. Quy chuẩn Pull Request (PR)
1. **Tiêu đề PR bắt buộc có mã Jira ở đầu**:
   `[FPDP-11] feat(identity): implement JWT authentication and RBAC`
2. **Base branch**: Luôn chọn `develop` (trừ đợt release cuối mới merge `develop` -> `main`).
3. **CI Checks**: Toàn bộ job trong `.github/workflows/ci.yml` (kiểm tra build 4 microservices, Nginx config, Web typecheck, kiểm tra rò rỉ `.env` và kiểm tra mã `FPDP-`) phải đạt trạng thái xanh trước khi **Squash and merge**.
