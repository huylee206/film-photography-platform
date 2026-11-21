import express, { Request, Response } from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import { pool } from "./config/db";

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT || 4002);

app.use(helmet());
app.use(cors());
app.use(express.json());

const SEED_SPACES = [
  {
    id: "sp-01",
    name: "Saigon Silver Halide Darkroom #1",
    spaceType: "DARKROOM",
    hourlyRate: 180000,
    dimensions: "4.5m x 3.2m (Tối đa 3 người)",
    lightingSpec: "Đèn đỏ safelight Ilford SL1 + Đèn rọi Beseler 23CIII",
    ventilationSpec: "Quạt hút công nghiệp 2 chiều khử mùi hóa chất D-76/Fixer",
  },
  {
    id: "sp-02",
    name: "ChoLon Medium Format Analog Studio",
    spaceType: "ANALOG_STUDIO",
    hourlyRate: 320000,
    dimensions: "6.0m x 5.0m (Trần cao 3.8m)",
    lightingSpec: "Profoto D2 500Ws + Phông giấy vô cực + Ánh sáng tự nhiên hướng Bắc",
    ventilationSpec: "Điều hòa Inverter 2HP + Lọc không khí HEPA",
  },
  {
    id: "sp-03",
    name: "Kodak C-41 & ECN-2 Hybrid Processing Lab",
    spaceType: "HYBRID_LAB",
    hourlyRate: 250000,
    dimensions: "5.0m x 4.0m",
    lightingSpec: "Bàn soi phim chuẩn CRI 98+ 5000K + Máy scan Noritsu HS-1800",
    ventilationSpec: "Tủ hút khí độc chuyên dụng cho hóa chất tráng màu",
  },
];

app.get("/health", async (_req: Request, res: Response) => {
  let dbStatus = "disconnected";
  try {
    await pool.query("SELECT 1");
    dbStatus = "connected";
  } catch {
    dbStatus = "unreachable";
  }
  res.json({
    service: "catalog-booking-service",
    domain: "CreativeSpaces, Equipment, Atomic GiST Booking, QR Session & VNPay",
    port: PORT,
    schema: "catalog_booking",
    database: dbStatus,
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/v1/spaces", async (req: Request, res: Response) => {
  const { type } = req.query as { type?: string };
  try {
    const result = await pool.query(
      "SELECT id, name, space_type AS \"spaceType\", hourly_rate AS \"hourlyRate\", dimensions, lighting_spec AS \"lightingSpec\", ventilation_spec AS \"ventilationSpec\" FROM catalog_booking.creative_spaces ORDER BY created_at ASC"
    );
    if (result.rows.length > 0) {
      const filtered = type ? result.rows.filter((r) => r.spaceType === type) : result.rows;
      res.json({ source: "postgres", data: filtered });
      return;
    }
  } catch {
    // Fallback to seed data when running without DB container
  }
  const filtered = type ? SEED_SPACES.filter((s) => s.spaceType === type) : SEED_SPACES;
  res.json({ source: "seed", data: filtered });
});

app.get("/api/v1/resources", (_req: Request, res: Response) => {
  res.json({
    service: "catalog-booking-service",
    categories: ["REUSABLE_EQUIPMENT", "CONSUMABLE_MATERIAL"],
  });
});

app.post("/api/v1/bookings", (req: Request, res: Response) => {
  res.status(201).json({
    service: "catalog-booking-service",
    concurrencyControl: "PostgreSQL EXCLUDE USING gist (tstzrange)",
    payload: req.body,
  });
});

app.get("/api/v1/packages", (_req: Request, res: Response) => {
  res.json({ service: "catalog-booking-service", data: [] });
});

app.post("/api/v1/sessions/check-in", (_req: Request, res: Response) => {
  res.json({ service: "catalog-booking-service", status: "QR_CHECKIN_READY" });
});

app.post("/api/v1/payments/vnpay-create", (_req: Request, res: Response) => {
  res.json({ service: "catalog-booking-service", gateway: "VNPAY_SANDBOX_READY" });
});

app.listen(PORT, () => {
  console.log(`[catalog-booking-service] SOA Microservice listening on port ${PORT}`);
});
