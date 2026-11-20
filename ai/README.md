# ai (FPDP AI Service - Python FastAPI)

Microservice AI tách riêng khỏi Backend, giao tiếp qua REST (`AIServicePort`).

## 7 Tính năng AI
1. Gợi ý không gian/thiết bị/gói dịch vụ (`/api/v1/ai/recommend-spaces`)
2. Tìm kiếm ngữ nghĩa bài viết (`pgvector` + `/api/v1/ai/semantic-search`)
3. Trợ lý hỏi đáp nhiếp ảnh phim (RAG)
4. Cải thiện & khôi phục ảnh phim cũ
5. Dự báo nhu cầu đặt chỗ
6. Tối ưu phân bổ tài nguyên dùng chung
7. Định giá động theo công suất (`/api/v1/ai/dynamic-pricing`)

## Lệnh chạy & Kiểm thử
```bash
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
pytest -q
```
