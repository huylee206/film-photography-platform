-- Chạy tự động lần đầu khi khởi tạo container PostgreSQL
CREATE EXTENSION IF NOT EXISTS "pgcrypto";    -- Hàm sinh UUIDv4 gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "btree_gist";  -- Ràng buộc EXCLUDE USING gist chống trùng lịch đặt chỗ
CREATE EXTENSION IF NOT EXISTS "vector";      -- pgvector lưu embedding 768 chiều cho Semantic Search & RAG
