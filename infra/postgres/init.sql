-- ============================================================================
-- FILM PHOTOGRAPHY PLATFORM - POSTGRESQL 16 SCHEMA (SOA DOMAIN ISOLATION)
-- Extensions: uuid-ossp, btree_gist (Anti-double-booking), vector (pgvector AI)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gist";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Separate logical schemas enforcing Service Data Ownership (Microservices)
CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS catalog_booking;
CREATE SCHEMA IF NOT EXISTS community;
CREATE SCHEMA IF NOT EXISTS ai_vectors;

-- ============================================================================
-- 1. BOUNDED CONTEXT: IDENTITY SERVICE (identity.*)
-- ============================================================================
CREATE TYPE identity.user_role AS ENUM ('CUSTOMER', 'PROVIDER', 'EXPERT', 'ADMIN');

CREATE TABLE IF NOT EXISTS identity.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT,
    full_name VARCHAR(150) NOT NULL,
    avatar_url TEXT,
    phone VARCHAR(20),
    role identity.user_role NOT NULL DEFAULT 'CUSTOMER',
    oauth_provider VARCHAR(50),
    oauth_provider_id VARCHAR(255),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS identity.refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES identity.users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 2. BOUNDED CONTEXT: CATALOG & BOOKING SERVICE (catalog_booking.*)
-- ============================================================================
CREATE TYPE catalog_booking.space_type AS ENUM ('DARKROOM', 'ANALOG_STUDIO', 'HYBRID_LAB');
CREATE TYPE catalog_booking.booking_status AS ENUM (
    'PENDING_PAYMENT',
    'CONFIRMED',
    'CHECKED_IN',
    'COMPLETED',
    'CANCELLED'
);

CREATE TABLE IF NOT EXISTS catalog_booking.creative_spaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL, -- Cross-service reference to identity.users(id)
    name VARCHAR(200) NOT NULL,
    space_type catalog_booking.space_type NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    hourly_rate NUMERIC(12, 2) NOT NULL CHECK (hourly_rate >= 0),
    capacity INT NOT NULL DEFAULT 2,
    dimensions VARCHAR(120),
    lighting_spec TEXT,
    ventilation_spec TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS catalog_booking.reusable_equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    space_id UUID REFERENCES catalog_booking.creative_spaces(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(80) NOT NULL, -- ENLARGER, MEDIUM_FORMAT_CAMERA, SCANNER, LIGHT_METER
    serial_number VARCHAR(100) UNIQUE,
    hourly_rental_fee NUMERIC(12, 2) NOT NULL DEFAULT 0,
    condition_status VARCHAR(50) NOT NULL DEFAULT 'GOOD',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS catalog_booking.consumable_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL,
    name VARCHAR(150) NOT NULL,
    material_type VARCHAR(80) NOT NULL, -- FILM_ROLL, DEVELOPER_CHEM, FIXER_CHEM, PHOTO_PAPER
    unit VARCHAR(30) NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS catalog_booking.service_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL,
    name VARCHAR(180) NOT NULL,
    description TEXT,
    bundle_price NUMERIC(12, 2) NOT NULL CHECK (bundle_price >= 0),
    duration_hours INT NOT NULL DEFAULT 3,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Atomic Multi-Resource Booking with PostgreSQL GiST Exclusion Constraint
CREATE TABLE IF NOT EXISTS catalog_booking.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL, -- Cross-service reference to identity.users(id)
    space_id UUID NOT NULL REFERENCES catalog_booking.creative_spaces(id),
    package_id UUID REFERENCES catalog_booking.service_packages(id),
    time_slot TSTZRANGE NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    status catalog_booking.booking_status NOT NULL DEFAULT 'PENDING_PAYMENT',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    EXCLUDE USING gist (
        space_id WITH =,
        time_slot WITH &&
    ) WHERE (status IN ('PENDING_PAYMENT', 'CONFIRMED', 'CHECKED_IN'))
);

CREATE TABLE IF NOT EXISTS catalog_booking.booking_equipment_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES catalog_booking.bookings(id) ON DELETE CASCADE,
    equipment_id UUID NOT NULL REFERENCES catalog_booking.reusable_equipment(id),
    time_slot TSTZRANGE NOT NULL,
    fee NUMERIC(12, 2) NOT NULL DEFAULT 0,
    EXCLUDE USING gist (
        equipment_id WITH =,
        time_slot WITH &&
    )
);

CREATE TABLE IF NOT EXISTS catalog_booking.service_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID UNIQUE NOT NULL REFERENCES catalog_booking.bookings(id) ON DELETE CASCADE,
    qr_token VARCHAR(255) UNIQUE NOT NULL,
    checked_in_at TIMESTAMPTZ,
    checked_out_at TIMESTAMPTZ,
    staff_notes TEXT
);

CREATE TABLE IF NOT EXISTS catalog_booking.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES catalog_booking.bookings(id),
    provider VARCHAR(40) NOT NULL DEFAULT 'VNPAY',
    transaction_ref VARCHAR(120) UNIQUE NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(40) NOT NULL DEFAULT 'PENDING',
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 3. BOUNDED CONTEXT: COMMUNITY & ANALYTICS SERVICE (community.*)
-- ============================================================================
CREATE TABLE IF NOT EXISTS community.posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL,
    title VARCHAR(250) NOT NULL,
    content TEXT NOT NULL,
    film_stock_tag VARCHAR(100),
    is_expert_article BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS community.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID UNIQUE NOT NULL,
    customer_id UUID NOT NULL,
    space_id UUID NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS community.workshops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expert_id UUID NOT NULL,
    space_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    ticket_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    max_participants INT NOT NULL DEFAULT 10,
    scheduled_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 4. BOUNDED CONTEXT: AI MICROSERVICE (ai_vectors.*)
-- ============================================================================
CREATE TABLE IF NOT EXISTS ai_vectors.space_embeddings (
    space_id UUID PRIMARY KEY,
    content_summary TEXT NOT NULL,
    embedding vector(1536),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SEED DATA FOR INITIAL VERIFICATION
-- ============================================================================
INSERT INTO identity.users (id, email, full_name, role, is_verified)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@filmplatform.vn', 'System Admin', 'ADMIN', TRUE),
    ('00000000-0000-0000-0000-000000000002', 'provider@filmplatform.vn', 'Saigon Analog Lab', 'PROVIDER', TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO catalog_booking.creative_spaces (
    provider_id, name, space_type, description, address, hourly_rate, capacity, dimensions, lighting_spec, ventilation_spec
)
VALUES
    (
        '00000000-0000-0000-0000-000000000002',
        'Saigon Silver Halide Darkroom #1',
        'DARKROOM',
        'Phòng tối rọi ảnh đen trắng chuẩn Ilford với 2 máy rọi Beseler 23CIII.',
        'Quận 1, TP. Hồ Chí Minh',
        180000,
        3,
        '4.5m x 3.2m (Tối đa 3 người)',
        'Đèn đỏ safelight Ilford SL1 + Đèn rọi Beseler 23CIII',
        'Quạt hút công nghiệp 2 chiều khử mùi hóa chất D-76/Fixer'
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        'ChoLon Medium Format Analog Studio',
        'ANALOG_STUDIO',
        'Studio chụp chân dung máy phim Medium/Large Format với hệ thống đèn Profoto.',
        'Quận 5, TP. Hồ Chí Minh',
        320000,
        6,
        '6.0m x 5.0m (Trần cao 3.8m)',
        'Profoto D2 500Ws + Phông giấy vô cực + Ánh sáng tự nhiên hướng Bắc',
        'Điều hòa Inverter 2HP + Lọc không khí HEPA'
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        'Kodak C-41 & ECN-2 Hybrid Processing Lab',
        'HYBRID_LAB',
        'Không gian tráng phim màu tự động Jobo CPP3 kèm trạm scan Noritsu HS-1800.',
        'Quận 3, TP. Hồ Chí Minh',
        250000,
        4,
        '5.0m x 4.0m',
        'Bàn soi phim chuẩn CRI 98+ 5000K + Máy scan Noritsu HS-1800',
        'Tủ hút khí độc chuyên dụng cho hóa chất tráng màu'
    );
