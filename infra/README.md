# infra

Hạ tầng dùng chung cho toàn hệ thống:

- `postgres/init.sql`: Kích hoạt các extension PostgreSQL (`pgcrypto`, `btree_gist`, `vector`).
- `postgres/001_schema.sql`: Toàn bộ bảng dữ liệu, khóa ngoại, index và ràng buộc `EXCLUDE USING gist` chống trùng lịch đặt chỗ.
- `postgres/002_seed.sql`: Dữ liệu mẫu phục vụ phát triển & demo (tài khoản mẫu, phòng tối, studio, thiết bị, vật tư, gói combo).
- Docker Compose gốc nằm ở `../docker-compose.yml`.
