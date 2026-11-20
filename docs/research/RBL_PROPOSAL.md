# Đề cương Nghiên cứu (Research-Based Learning) – FPDP AI

## 1. Tổng quan bài toán nghiên cứu
Tích hợp 7 mô-đun trí tuệ nhân tạo và tối ưu hóa vận hành cho nền tảng dịch vụ nhiếp ảnh phim:

1. **Hybrid Recommender System**: Kết hợp lọc cộng tác (Collaborative Filtering) và lọc theo nội dung thông số phòng tối (`lightingSpec`, `ventilationSpec`, khổ phim 35mm/120/4x5).
2. **Semantic Search với `pgvector`**: Sử dụng mô hình nhúng câu (`all-MiniLM-L6-v2` / `bge-m3`) để truy vấn bài viết kỹ thuật tráng rửa theo ngữ nghĩa tự nhiên.
3. **Photography RAG Assistant**: Hỏi đáp công thức pha thuốc tráng (D-76, ID-11, Rodinal, C-41) có trích dẫn nguồn từ `KnowledgeArticle` của chuyên gia.
4. **Film Image Restoration & Denoising**: Khử hạt nhiễu (film grain denoising), phục hồi vết xước âm bản và cân bằng màu ảnh scan phim cũ.
5. **Demand Forecasting**: Dự báo công suất đặt phòng theo khung giờ cao điểm cuối tuần bằng chuỗi thời gian (Prophet / LightGBM).
6. **Multi-Resource Scheduling Optimization**: Tối ưu phân bổ thiết bị dùng chung (máy rọi, máy scan film) giữa các phòng tối liền kề.
7. **Dynamic AI Pricing (`DynamicAIPricingStrategy`)**: Điều chỉnh hệ số giá `demandFactor` theo tỷ lệ lấp đầy dự báo nhằm cân bằng tải giờ thấp điểm.
