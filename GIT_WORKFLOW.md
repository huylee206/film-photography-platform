# GIT WORKFLOW – Film Photography Platform

Tài liệu quy ước Git cho cả nhóm. Đặt file này ở thư mục gốc của repo và commit đầu tiên.

## 1. Cấu trúc repo (monorepo)

```
film-platform/
├── backend/      # API (NestJS / Spring Boot)
├── web/          # Web (React)
├── mobile/       # Mobile (Flutter / React Native)
├── ai/           # AI service (FastAPI)
├── docs/         # Tài liệu, sơ đồ, ERD, OpenAPI
├── .github/      # CI + PR template
├── GIT_WORKFLOW.md
├── .gitmessage   # Template commit message
├── .gitignore
└── README.md
```

## 2. Chiến lược nhánh

| Nhánh | Mục đích | Ai được push trực tiếp |
|---|---|---|
| `main` | Bản ổn định, dùng để demo/nộp | Không ai (chỉ merge từ `develop` qua PR) |
| `develop` | Nhánh tích hợp hằng ngày | Không ai (chỉ merge qua PR) |
| `feature/<mã-task>-<mô-tả>` | Làm tính năng mới | Người nhận task |
| `fix/<mã-task>-<mô-tả>` | Sửa lỗi | Người nhận task |
| `docs/<mô-tả>` | Chỉ sửa tài liệu | Bất kỳ ai |
| `hotfix/<mô-tả>` | Sửa lỗi gấp trên `main` | TL |

Ví dụ tên nhánh:

```
feature/P2-03-jwt-auth
feature/P4-05-booking-availability-check
fix/P4-06-double-booking-race
docs/update-erd
```

Luồng làm việc:

```
develop ──► feature/P4-05-... ──► Pull Request ──► review ──► merge vào develop
develop ──► (cuối mỗi mốc) ──► Pull Request ──► merge vào main + gắn tag
```

## 3. Quy ước commit (Conventional Commits)

Định dạng:

```
<type>(<scope>): <mô tả ngắn, thì hiện tại, không chấm cuối>

[nội dung chi tiết nếu cần]

[Refs: P4-05]
```

### type

| type | Dùng khi |
|---|---|
| `feat` | Thêm tính năng |
| `fix` | Sửa lỗi |
| `docs` | Chỉ sửa tài liệu |
| `style` | Format, khoảng trắng (không đổi logic) |
| `refactor` | Cấu trúc lại code, không đổi hành vi |
| `perf` | Cải thiện hiệu năng |
| `test` | Thêm/sửa test |
| `build` | Build, dependency, Docker |
| `ci` | GitHub Actions, pipeline |
| `chore` | Việc vặt khác |
| `revert` | Hoàn tác commit |

### scope

`auth`, `space`, `resource`, `booking`, `package`, `session`, `payment`, `community`, `review`, `dashboard`, `admin`, `ai`, `db`, `infra`, `web`, `mobile`

### Ví dụ commit tốt

```
chore(infra): init monorepo structure
build(infra): add docker compose for postgres redis minio
feat(db): add initial migration from ERD v1
feat(auth): implement jwt access and refresh token
feat(auth): add google oauth2 login
feat(space): add crud api for darkroom and studio
feat(resource): add maintenance schedule and block booking
feat(booking): check availability of all resources in one transaction
fix(booking): prevent double booking with exclusion constraint
test(booking): add concurrent booking test for same slot
feat(session): generate qr code for check-in
feat(web): add provider dashboard revenue chart
feat(mobile): add qr scanner for check-in
feat(ai): add content-based room recommender
docs(docs): add openapi spec for booking module
ci(infra): run lint and test on pull request
```

### Ví dụ commit xấu (tránh)

```
update
fix bug
done
asdf
final final v2
```

## 4. Thiết lập lần đầu (làm một lần)

### Người tạo repo (TL)

```bash
mkdir film-platform && cd film-platform
git init -b main
mkdir backend web mobile ai docs .github
# copy GIT_WORKFLOW.md, .gitmessage, .gitignore, README.md vào đây

git add .
git commit -m "chore(infra): init monorepo with git workflow docs"

git remote add origin <URL_REPO_GITHUB>
git push -u origin main

git checkout -b develop
git push -u origin develop
```

Sau đó vào GitHub: Settings → Branches → bật **Branch protection** cho `main` và `develop` (bắt buộc Pull Request, tối thiểu 1 review, CI phải xanh).

### Mỗi thành viên

```bash
git clone <URL_REPO_GITHUB>
cd film-platform
git checkout develop

# Cấu hình danh tính
git config user.name  "Ten Cua Ban"
git config user.email "email@cua-ban.com"

# Dùng template commit
git config commit.template .gitmessage
```

## 5. Quy trình làm một task

```bash
# 1. Cập nhật develop mới nhất
git checkout develop
git pull origin develop

# 2. Tạo nhánh theo mã task
git checkout -b feature/P4-05-booking-availability-check

# 3. Code, commit nhỏ và thường xuyên
git add <file>            # tránh dùng "git add ." bừa bãi
git commit                # mở template .gitmessage

# 4. Trước khi tạo PR: đồng bộ với develop
git fetch origin
git rebase origin/develop # hoặc git merge origin/develop nếu chưa quen rebase

# 5. Đẩy nhánh và tạo Pull Request vào develop
git push -u origin feature/P4-05-booking-availability-check
```

Sau khi PR được duyệt: dùng **Squash and merge** (hoặc Merge commit), rồi xóa nhánh.

```bash
git checkout develop
git pull origin develop
git branch -d feature/P4-05-booking-availability-check
```

## 6. Quy tắc Pull Request

- Tiêu đề theo Conventional Commits: `feat(booking): check availability of all resources`
- Liên kết task: ghi `Refs: P4-05` hoặc `Closes #<số issue>`.
- PR nhỏ (dưới khoảng 400 dòng thay đổi), một mục đích.
- Ít nhất **1 người khác** review; người viết không tự merge PR của mình (trừ khi cả nhóm đã thống nhất).
- CI (lint + test + build) phải xanh.
- Giải quyết hết comment trước khi merge.
- Không commit: secret, file `.env`, `node_modules`, file build, dữ liệu cá nhân.

### Mẫu mô tả PR (`.github/pull_request_template.md`)

```markdown
## Mô tả
<!-- Thay đổi gì và vì sao -->

## Task liên quan
Refs: P?-??

## Loại thay đổi
- [ ] feat
- [ ] fix
- [ ] refactor
- [ ] docs
- [ ] test

## Cách kiểm thử
<!-- Các bước để reviewer chạy lại -->

## Checklist
- [ ] Đã tự review code
- [ ] Có test hoặc đã ghi cách kiểm thử thủ công
- [ ] Đã cập nhật OpenAPI/tài liệu nếu có đổi API
- [ ] Không có secret trong code
- [ ] CI xanh
```

## 7. Template commit (`.gitmessage`)

Tạo file `.gitmessage` ở gốc repo với nội dung sau:

```
# <type>(<scope>): <mô tả ngắn, tối đa 72 ký tự>
#
# Nội dung chi tiết: vì sao thay đổi, thay đổi gì (xuống dòng ~72 ký tự)
#
# Refs: P?-??
#
# type : feat | fix | docs | style | refactor | perf | test | build | ci | chore | revert
# scope: auth | space | resource | booking | package | session | payment |
#        community | review | dashboard | admin | ai | db | infra | web | mobile
```

## 8. `.gitignore` gợi ý (gốc repo)

```gitignore
# Môi trường & bí mật
.env
.env.*
!.env.example
*.pem
*.key

# Node / Web
node_modules/
dist/
build/
.next/
coverage/

# Python / AI
__pycache__/
*.pyc
.venv/
venv/
*.ipynb_checkpoints/
ai/models/*.pt
ai/models/*.onnx

# Java (nếu dùng Spring Boot)
target/
*.class

# Mobile
mobile/.dart_tool/
mobile/build/
mobile/android/.gradle/
mobile/ios/Pods/

# Docker / dữ liệu local
docker-data/
minio-data/
pgdata/

# IDE / OS
.idea/
.vscode/*
!.vscode/extensions.json
.DS_Store
Thumbs.db
```

## 9. Tag phiên bản theo mốc

```bash
git checkout main
git pull origin main
git tag -a v0.1.0 -m "MVP: auth + space + resource"
git tag -a v0.2.0 -m "MVP: booking + payment"
git tag -a v1.0.0 -m "Bản nộp cuối"
git push origin --tags
```

| Tag | Mốc |
|---|---|
| `v0.1.0` | Hết Phase 3 |
| `v0.2.0` | Hết Phase 4 (MVP đặt chỗ) |
| `v0.3.0` | Hết Phase 7 |
| `v0.9.0` | Hết Phase 8 (có AI) |
| `v1.0.0` | Bản bảo vệ |

## 10. Xử lý tình huống thường gặp

| Tình huống | Lệnh |
|---|---|
| Sửa message commit gần nhất (chưa push) | `git commit --amend` |
| Bỏ file khỏi staging | `git restore --staged <file>` |
| Hủy thay đổi chưa commit của một file | `git restore <file>` |
| Cất tạm việc đang dở | `git stash` / `git stash pop` |
| Hoàn tác commit đã push an toàn | `git revert <hash>` |
| Gặp conflict khi rebase | Sửa file, `git add <file>`, `git rebase --continue` |
| Xem lịch sử gọn | `git log --oneline --graph --decorate -20` |
| Lỡ commit secret | Đổi secret ngay, báo TL để xử lý lịch sử; không chỉ xóa file rồi push |

**Không dùng `git push --force` lên `main`/`develop`.** Nếu cần force trên nhánh cá nhân, dùng `git push --force-with-lease`.

## 11. Commit đầu tiên gợi ý (copy chạy luôn)

```bash
git add GIT_WORKFLOW.md .gitmessage .gitignore README.md
git commit -m "chore(infra): add git workflow, commit template and gitignore" \
           -m "Refs: P0-03, P0-04"
git push origin main
```
