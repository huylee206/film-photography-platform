# Software Requirements Specification (SRS)
## Film Photography Creative Space & Analog Lab Platform

### 1. Vai trò người dùng (4 Roles RBAC)
1. **CUSTOMER (Nhiếp ảnh gia / Khách hàng)**: Tìm kiếm phòng tối, studio phim; đặt lịch kết hợp không gian + thiết bị + hóa chất; thanh toán VNPay; nhận mã QR check-in; tham gia cộng đồng và workshop.
2. **PROVIDER (Chủ Lab / Chủ Studio)**: Đăng ký và vận hành `CreativeSpace`, quản lý kho thiết bị/vật tư, tạo gói dịch vụ (`ServicePackage`), quét QR check-in/out khách và theo dõi doanh thu.
3. **EXPERT (Chuyên gia nhiếp ảnh phim)**: Đăng bài hướng dẫn kỹ thuật tráng/rọi, công thức hóa chất (`Film Recipe`) và tổ chức Workshop thực hành tại Lab.
4. **ADMIN (Quản trị viên nền tảng)**: Kiểm duyệt Provider, giám sát giao dịch, xử lý tranh chấp và quản lý toàn hệ thống.

### 2. Yêu cầu phi chức năng cốt lõi
* **Kiến trúc SOA & Microservices**: Tách biệt 4 microservices độc lập giao tiếp qua `Nginx API Gateway` và `Redis Event Bus`, đóng gói 100% bằng `Docker Compose`.
* **Chống trùng lịch tuyệt đối (Zero Double-Booking)**: Ràng buộc mức cơ sở dữ liệu bằng `PostgreSQL EXCLUDE USING gist` trên kiểu dữ liệu khoảng thời gian `TSTZRANGE`.
