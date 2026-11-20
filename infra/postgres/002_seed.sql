-- Dữ liệu mẫu khởi tạo phục vụ phát triển & demo
INSERT INTO users (id, email, password_hash, full_name, is_verified) VALUES
    ('11111111-1111-1111-1111-111111111101', 'admin@fpdp.vn', '$2b$10$demoHashAdminOnlyForDev', 'FPDP System Admin', TRUE),
    ('11111111-1111-1111-1111-111111111102', 'provider.saigon@fpdp.vn', '$2b$10$demoHashProviderOnlyForDev', 'Saigon Analog Lab', TRUE),
    ('11111111-1111-1111-1111-111111111103', 'expert.minh@fpdp.vn', '$2b$10$demoHashExpertOnlyForDev', 'Trần Hoàng Minh (Master Printer)', TRUE),
    ('11111111-1111-1111-1111-111111111104', 'photographer.dat@fpdp.vn', '$2b$10$demoHashPhotoOnlyForDev', 'Nguyễn Quốc Đạt', TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO user_roles (user_id, role) VALUES
    ('11111111-1111-1111-1111-111111111101', 'ADMINISTRATOR'),
    ('11111111-1111-1111-1111-111111111102', 'SERVICE_PROVIDER'),
    ('11111111-1111-1111-1111-111111111103', 'PHOTOGRAPHY_EXPERT'),
    ('11111111-1111-1111-1111-111111111104', 'PHOTOGRAPHER')
ON CONFLICT DO NOTHING;

INSERT INTO service_provider_profiles (provider_id, business_name, tax_code, address, district, approval_status, approved_by, approved_at) VALUES
    ('11111111-1111-1111-1111-111111111102', 'Saigon Darkroom & Studio Collective', '0318999888', '142 Nguyễn Đình Chiểu, Phường Võ Thị Sáu', 'Quận 3', 'APPROVED', '11111111-1111-1111-1111-111111111101', NOW())
ON CONFLICT (provider_id) DO NOTHING;

INSERT INTO creative_spaces (id, provider_id, name, space_type, description, dimensions, max_capacity, lighting_spec, ventilation_spec, acoustic_spec, hourly_rate) VALUES
    ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111102', 'Phòng Tối B&W Đỏ Ilford #01', 'DARKROOM', 'Phòng tối chuyên tráng và rọi giấy bạc gelatin khổ 35mm & Medium Format 120.', '4.5m x 3.2m', 3, 'Đèn safelight Ilford SL1 15W chống sương mù giấy', 'Quạt hút khí hóa chất 2 chiều 350 m3/h + bồn rửa nước tuần hoàn', 'Cửa cách sáng 2 lớp chống lọt sáng tuyệt đối', 180000),
    ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111102', 'Studio Ánh Sáng Tự Nhiên & Strobes', 'STUDIO', 'Studio chụp chân dung phim Medium/Large Format với phông nền vô cực.', '7.0m x 5.0m', 8, 'Cửa sổ hướng Bắc + 3 đèn Profoto D2 500Ws', 'Điều hòa Inverter 24000 BTU vận hành êm', 'Tiêu âm trần và vách gỗ tiêu chuẩn < 32dB', 320000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO resources (id, provider_id, space_id, resource_kind, name, unit_price, serial_number, category, equipment_status, unit_of_measure, stock_quantity, min_threshold) VALUES
    ('33333333-3333-3333-3333-333333333301', '11111111-1111-1111-1111-111111111102', '22222222-2222-2222-2222-222222222201', 'REUSABLE', 'Máy rọi ảnh Beseler 23C III-XL', 65000, 'BSL-23C-0091', 'Enlarger', 'AVAILABLE', NULL, 1, 0),
    ('33333333-3333-3333-3333-333333333302', '11111111-1111-1111-1111-111111111102', '22222222-2222-2222-2222-222222222201', 'CONSUMABLE', 'Bộ thuốc tráng Ilford ID-11 + Rapid Fixer (1L)', 45000, NULL, 'Chemistry', 'AVAILABLE', 'bộ 1L', 24, 5),
    ('33333333-3333-3333-3333-333333333303', '11111111-1111-1111-1111-111111111102', '22222222-2222-2222-2222-222222222201', 'CONSUMABLE', 'Giấy ảnh Ilford Multigrade RC Deluxe 8x10 (10 tờ)', 120000, NULL, 'Photo Paper', 'AVAILABLE', 'xấp 10 tờ', 15, 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO service_packages (id, provider_id, title, description, bundle_discount_rate) VALUES
    ('44444444-4444-4444-4444-444444444401', '11111111-1111-1111-1111-111111111102', 'Combo Tráng & Rọi Đen Trắng Trọn Gói (3 Giờ)', 'Bao gồm Phòng Tối #01, Máy rọi Beseler 23C, thuốc tráng ID-11 và 10 tờ giấy ảnh 8x10.', 0.1500)
ON CONFLICT (id) DO NOTHING;

INSERT INTO package_items (id, package_id, bookable_type, bookable_id, quantity) VALUES
    ('55555555-5555-5555-5555-555555555501', '44444444-4444-4444-4444-444444444401', 'SPACE', '22222222-2222-2222-2222-222222222201', 1),
    ('55555555-5555-5555-5555-555555555502', '44444444-4444-4444-4444-444444444401', 'RESOURCE', '33333333-3333-3333-3333-333333333301', 1),
    ('55555555-5555-5555-5555-555555555503', '44444444-4444-4444-4444-444444444401', 'RESOURCE', '33333333-3333-3333-3333-333333333302', 1),
    ('55555555-5555-5555-5555-555555555504', '44444444-4444-4444-4444-444444444401', 'RESOURCE', '33333333-3333-3333-3333-333333333303', 1)
ON CONFLICT (id) DO NOTHING;
