import express, { Request, Response } from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import { pool } from "./config/db";

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT || 4003);

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/health", async (_req: Request, res: Response) => {
  let dbStatus = "disconnected";
  try {
    await pool.query("SELECT 1");
    dbStatus = "connected";
  } catch {
    dbStatus = "unreachable";
  }
  res.json({
    service: "community-service",
    domain: "Film Community, Expert Articles, Workshops, Reviews & Analytics",
    port: PORT,
    schema: "community",
    database: dbStatus,
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/v1/community/posts", (_req: Request, res: Response) => {
  res.json({ service: "community-service", data: [] });
});

app.get("/api/v1/workshops", (_req: Request, res: Response) => {
  res.json({ service: "community-service", data: [] });
});

app.get("/api/v1/reviews", (_req: Request, res: Response) => {
  res.json({ service: "community-service", data: [] });
});

app.get("/api/v1/dashboard/summary", (_req: Request, res: Response) => {
  res.json({
    service: "community-service",
    metrics: { activeSpaces: 3, totalBookings: 0, monthlyRevenueVnd: 0 },
  });
});

app.listen(PORT, () => {
  console.log(`[community-service] SOA Microservice listening on port ${PORT}`);
});
