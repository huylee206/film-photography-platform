# Đặc tả Yêu cầu Phần mềm (SRS) – FPDP

## 1. Phạm vi & Mục tiêu
Xây dựng nền tảng **Film Photography & Darkroom Platform (FPDP)** kết nối cộng đồng nhiếp ảnh phim với các phòng tối (Darkroom), phòng chụp (Studio), thiết bị chuyên dụng và vật tư tráng rọi.

## 2. Phân quyền người dùng (Actors)
1. **Photographer**: Tìm kiếm phòng, đặt chỗ đa tài nguyên, thanh toán trực tuyến, check-in QR, viết đánh giá, đặt câu hỏi cho AI và đăng ký workshop.
2. **Service Provider**: Quản lý hồ sơ doanh nghiệp, thiết lập phòng tối/studio với thông số vật lý chuyên biệt, quản lý thiết bị tái sử dụng & vật tư tiêu hao, tạo gói combo, xem thống kê.
3. **Photography Expert**: Xuất bản bài viết kỹ thuật nhiếp ảnh phim, tổ chức workshop thực hành.
4. **Administrator**: Xét duyệt hồ sơ Service Provider (`approve`/`reject`), giám sát giao dịch và xử lý khiếu nại.

## 3. Yêu cầu chức năng cốt lõi (Functional Requirements)
- **FR-01 (Xác thực & Phân quyền)**: Đăng ký/đăng nhập bằng Email + Mật khẩu (JWT Access/Refresh Token) và Google OAuth 2.0; một người dùng có thể sở hữu nhiều vai trò (`Set<RoleType>`).
- **FR-02 (Quản lý Không gian Sáng tạo)**: Lưu trữ đầy đủ thông số đặc thù của phòng tối/studio: kích thước (`dimensions`), sức chứa (`maxCapacity`), thông số ánh sáng safelight/strobe (`lightingSpec`), thông gió xử lý hóa chất (`ventilationSpec`), cách âm (`acousticSpec`).
- **FR-03 (Quản lý Thiết bị & Vật tư)**:
  - `ReusableEquipment`: Theo dõi số serial, trạng thái (`AVAILABLE`, `MAINTENANCE`...) và lịch bảo trì định kỳ.
  - `ConsumableMaterial`: Theo dõi tồn kho (`stockQuantity`) và ngưỡng cảnh báo (`minThreshold`).
- **FR-04 (Gói dịch vụ Composite)**: Gom nhiều `CreativeSpace` và `Resource` thành `ServicePackage` với tỷ lệ giảm giá gói (`bundleDiscountRate`).
- **FR-05 (Đặt chỗ nguyên tử & Chống trùng lịch)**: Đặt đồng thời nhiều tài nguyên trong một `Reservation`, khóa giá tại thời điểm đặt (`lockedPrice`), đảm bảo không trùng khung giờ.
- **FR-06 (Vòng đời phiên sử dụng - State Pattern)**: `PENDING` -> `CONFIRMED` -> `IN_SESSION` (Check-in bằng mã QR) -> `COMPLETED` (Check-out, tính phụ phí vật tư phát sinh nếu có) hoặc `CANCELLED`.
- **FR-07 (Hệ sinh thái AI)**: Gợi ý không gian, tìm kiếm ngữ nghĩa bài viết (`pgvector`), trợ lý hỏi đáp RAG, phục chế ảnh phim, dự báo nhu cầu và định giá động.

## 4. Yêu cầu phi chức năng (Non-Functional Requirements)
- **Tính toàn vẹn dữ liệu**: Đảm bảo ACID cho mọi giao dịch đặt chỗ và trừ tồn kho.
- **Hiệu năng**: Thời gian phản hồi API tìm kiếm và kiểm tra lịch trống < 200ms.
- **Bảo mật**: Mật khẩu băm bằng `bcrypt` (cost >= 10), tách biệt biến môi trường, kiểm soát truy cập theo vai trò (RBAC).
