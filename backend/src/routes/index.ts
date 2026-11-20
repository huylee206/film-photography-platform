import { Router } from "express";
import {
  DynamicAIPricingStrategy,
  StandardPricingStrategy,
} from "../domain/pricing.strategy";

export const apiRouter = Router();

apiRouter.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    service: "fpdp-backend",
    timestamp: new Date().toISOString(),
  });
});

// Dữ liệu mẫu đồng bộ với 002_seed.sql để Frontend/Mobile tích hợp ngay
const sampleSpaces = [
  {
    id: "22222222-2222-2222-2222-222222222201",
    name: "Phòng Tối B&W Đỏ Ilford #01",
    spaceType: "DARKROOM",
    dimensions: "4.5m x 3.2m",
    maxCapacity: 3,
    lightingSpec: "Đèn safelight Ilford SL1 15W chống sương mù giấy",
    ventilationSpec: "Quạt hút khí hóa chất 2 chiều 350 m3/h",
    acousticSpec: "Cửa cách sáng 2 lớp chống lọt sáng tuyệt đối",
    hourlyRate: 180000,
  },
  {
    id: "22222222-2222-2222-2222-222222222202",
    name: "Studio Ánh Sáng Tự Nhiên & Strobes",
    spaceType: "STUDIO",
    dimensions: "7.0m x 5.0m",
    maxCapacity: 8,
    lightingSpec: "Cửa sổ hướng Bắc + 3 đèn Profoto D2 500Ws",
    ventilationSpec: "Điều hòa Inverter 24000 BTU vận hành êm",
    acousticSpec: "Tiêu âm trần và vách gỗ < 32dB",
    hourlyRate: 320000,
  },
];

apiRouter.get("/spaces", (req, res) => {
  const { spaceType } = req.query;
  const filtered = spaceType
    ? sampleSpaces.filter((s) => s.spaceType === String(spaceType).toUpperCase())
    : sampleSpaces;
  res.json({ data: filtered, total: filtered.length });
});

apiRouter.post("/bookings/quote", (req, res) => {
  const { hourlyRate = 180000, startTime, endTime, pricingMode = "STANDARD" } =
    req.body || {};
  const start = startTime ? new Date(startTime) : new Date();
  const end = endTime
    ? new Date(endTime)
    : new Date(start.getTime() + 2 * 60 * 60 * 1000);

  const strategy =
    pricingMode === "DYNAMIC_AI"
      ? new DynamicAIPricingStrategy(1.15)
      : new StandardPricingStrategy();

  const estimatedTotal = strategy.computePrice(Number(hourlyRate), start, end);
  res.json({
    pricingMode,
    estimatedTotal,
    currency: "VND",
  });
});
