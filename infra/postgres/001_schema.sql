-- ============================================================================
-- FPDP (Film Photography & Darkroom Platform) - PostgreSQL 16 Schema DDL
-- Khớp 100% với Class Diagram & ERD
-- ============================================================================

-- 1. ENUM TYPES
DO $$ BEGIN
    CREATE TYPE role_type AS ENUM (
        'PHOTOGRAPHER',
        'SERVICE_PROVIDER',
        'PHOTOGRAPHY_EXPERT',
        'ADMINISTRATOR'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE approval_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE equipment_status AS ENUM ('AVAILABLE', 'IN_USE', 'MAINTENANCE', 'RETIRED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE reservation_status AS ENUM (
        'PENDING',
        'CONFIRMED',
        'IN_SESSION',
        'COMPLETED',
        'CANCELLED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('PENDING', 'SUCCEEDED', 'FAILED', 'REFUNDED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 2. ZONE 1: IDENTITY, ROLES & COMMUNITY
CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    full_name       VARCHAR(150) NOT NULL,
    avatar_url      TEXT,
    phone           VARCHAR(20),
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            role_type NOT NULL,
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role)
);

CREATE TABLE IF NOT EXISTS service_provider_profiles (
    provider_id     UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    business_name   VARCHAR(200) NOT NULL,
    tax_code        VARCHAR(50) NOT NULL UNIQUE,
    address         TEXT NOT NULL,
    district        VARCHAR(100),
    city            VARCHAR(100) NOT NULL DEFAULT 'Ho Chi Minh City',
    approval_status approval_status NOT NULL DEFAULT 'PENDING',
    reject_reason   TEXT,
    approved_by     UUID REFERENCES users(id),
    approved_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS knowledge_articles (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id           UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title               VARCHAR(255) NOT NULL,
    slug                VARCHAR(280) NOT NULL UNIQUE,
    content             TEXT NOT NULL,
    category            VARCHAR(100) NOT NULL,
    tags                TEXT[] DEFAULT '{}',
    is_published        BOOLEAN NOT NULL DEFAULT FALSE,
    published_at        TIMESTAMPTZ,
    embedding_vector    vector(768),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_knowledge_articles_embedding
    ON knowledge_articles USING ivfflat (embedding_vector vector_cosine_ops) WITH (lists = 50);

CREATE TABLE IF NOT EXISTS workshops (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    space_id        UUID, -- FK gắn sau khi tạo creative_spaces
    title           VARCHAR(255) NOT NULL,
    description     TEXT NOT NULL,
    start_time      TIMESTAMPTZ NOT NULL,
    end_time        TIMESTAMPTZ NOT NULL,
    max_seats       INT NOT NULL CHECK (max_seats > 0),
    ticket_price    NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. ZONE 2: BOOKABLE RESOURCES & COMPOSITE PACKAGES
CREATE TABLE IF NOT EXISTS creative_spaces (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id         UUID NOT NULL REFERENCES service_provider_profiles(provider_id) ON DELETE CASCADE,
    name                VARCHAR(200) NOT NULL,
    space_type          VARCHAR(50) NOT NULL CHECK (space_type IN ('DARKROOM', 'STUDIO', 'HYBRID')),
    description         TEXT,
    dimensions          VARCHAR(100),
    max_capacity        INT NOT NULL CHECK (max_capacity > 0),
    lighting_spec       TEXT,
    ventilation_spec    TEXT,
    acoustic_spec       TEXT,
    hourly_rate         NUMERIC(12, 2) NOT NULL CHECK (hourly_rate >= 0),
    cover_image_url     TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE workshops
    ADD CONSTRAINT fk_workshops_space
    FOREIGN KEY (space_id) REFERENCES creative_spaces(id) ON DELETE SET NULL;

-- Bảng gốc tài nguyên (Single-Table / Joined Inheritance cho Resource)
CREATE TABLE IF NOT EXISTS resources (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id             UUID NOT NULL REFERENCES service_provider_profiles(provider_id) ON DELETE CASCADE,
    space_id                UUID REFERENCES creative_spaces(id) ON DELETE SET NULL,
    resource_kind           VARCHAR(30) NOT NULL CHECK (resource_kind IN ('REUSABLE', 'CONSUMABLE')),
    name                    VARCHAR(200) NOT NULL,
    description             TEXT,
    unit_price              NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    -- Thuộc tính ReusableEquipment
    serial_number           VARCHAR(100),
    category                VARCHAR(100),
    equipment_status        equipment_status DEFAULT 'AVAILABLE',
    next_maintenance_date   DATE,
    -- Thuộc tính ConsumableMaterial
    unit_of_measure         VARCHAR(50),
    stock_quantity          INT DEFAULT 0 CHECK (stock_quantity >= 0),
    min_threshold           INT DEFAULT 5 CHECK (min_threshold >= 0),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_packages (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id             UUID NOT NULL REFERENCES service_provider_profiles(provider_id) ON DELETE CASCADE,
    title                   VARCHAR(200) NOT NULL,
    description             TEXT,
    bundle_discount_rate    NUMERIC(5, 4) NOT NULL DEFAULT 0.1000 CHECK (bundle_discount_rate >= 0 AND bundle_discount_rate <= 0.8000),
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS package_items (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id          UUID NOT NULL REFERENCES service_packages(id) ON DELETE CASCADE,
    bookable_type       VARCHAR(30) NOT NULL CHECK (bookable_type IN ('SPACE', 'RESOURCE')),
    bookable_id         UUID NOT NULL,
    quantity            INT NOT NULL DEFAULT 1 CHECK (quantity > 0)
);

-- 4. ZONE 3: RESERVATION LIFECYCLE & SESSION TRACKING
CREATE TABLE IF NOT EXISTS reservations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    photographer_id     UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    qr_code             VARCHAR(120) NOT NULL UNIQUE,
    start_time          TIMESTAMPTZ NOT NULL,
    end_time            TIMESTAMPTZ NOT NULL,
    total_amount        NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    pricing_strategy    VARCHAR(50) NOT NULL DEFAULT 'STANDARD',
    status              reservation_status NOT NULL DEFAULT 'PENDING',
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_reservation_time_range CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS reservation_allocations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id      UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    bookable_type       VARCHAR(30) NOT NULL CHECK (bookable_type IN ('SPACE', 'RESOURCE', 'PACKAGE')),
    bookable_id         UUID NOT NULL,
    allocated_qty       INT NOT NULL DEFAULT 1 CHECK (allocated_qty > 0),
    locked_price        NUMERIC(12, 2) NOT NULL CHECK (locked_price >= 0),
    time_range          TSTZRANGE NOT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    -- Chống trùng lịch cấp độ DB cho CreativeSpace (Exclusion Constraint với btree_gist)
    CONSTRAINT excl_space_no_double_booking
        EXCLUDE USING gist (
            bookable_id WITH =,
            time_range WITH &&
        )
        WHERE (bookable_type = 'SPACE' AND is_active = TRUE)
);

CREATE TABLE IF NOT EXISTS service_sessions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id      UUID NOT NULL UNIQUE REFERENCES reservations(id) ON DELETE CASCADE,
    actual_check_in     TIMESTAMPTZ,
    actual_check_out    TIMESTAMPTZ,
    extra_charges       NUMERIC(12, 2) NOT NULL DEFAULT 0,
    condition_notes     TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id      UUID NOT NULL REFERENCES reservations(id) ON DELETE RESTRICT,
    provider_gateway    VARCHAR(50) NOT NULL DEFAULT 'VNPAY',
    transaction_ref     VARCHAR(150) UNIQUE,
    amount              NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    status              payment_status NOT NULL DEFAULT 'PENDING',
    paid_at             TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reviews (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id      UUID NOT NULL UNIQUE REFERENCES reservations(id) ON DELETE CASCADE,
    author_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    space_id            UUID NOT NULL REFERENCES creative_spaces(id) ON DELETE CASCADE,
    rating              INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment             TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reservations_photographer ON reservations(photographer_id);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_creative_spaces_type ON creative_spaces(space_type, is_active);
CREATE INDEX IF NOT EXISTS idx_resources_provider ON resources(provider_id, resource_kind);
