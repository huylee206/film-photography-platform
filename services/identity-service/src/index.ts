import express, { Request, Response } from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import jwt from "jsonwebtoken";
import { pool } from "./config/db";

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT || 4001);
const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || "change_me_access_secret_min_32_chars_2026";

app.use(helmet());
app.use(cors());
app.use(express.json());

export type UserRole = "CUSTOMER" | "PROVIDER" | "EXPERT" | "ADMIN";

app.get("/health", async (_req: Request, res: Response) => {
  let dbStatus = "disconnected";
  try {
    await pool.query("SELECT 1");
    dbStatus = "connected";
  } catch {
    dbStatus = "unreachable";
  }
  res.json({
    service: "identity-service",
    domain: "Authentication, OAuth2 & 4-Role RBAC",
    port: PORT,
    schema: "identity",
    database: dbStatus,
    timestamp: new Date().toISOString(),
  });
});

// SOA Internal Service Endpoint: Token Introspection for peer microservices
app.post("/internal/verify-token", (req: Request, res: Response) => {
  const { token } = req.body as { token?: string };
  if (!token) {
    res.status(400).json({ valid: false, message: "Missing token" });
    return;
  }
  try {
    const decoded = jwt.verify(token, JWT_ACCESS_SECRET);
    res.json({ valid: true, user: decoded });
  } catch {
    res.status(401).json({ valid: false, message: "Invalid or expired token" });
  }
});

// Starter endpoints for FPDP-11 (Auth & RBAC)
app.post("/api/v1/auth/register", (req: Request, res: Response) => {
  const { email, fullName, role = "CUSTOMER" } = req.body as {
    email?: string;
    fullName?: string;
    role?: UserRole;
  };
  res.status(201).json({
    message: "Starter register endpoint ready for FPDP-11 implementation",
    user: { email, fullName, role },
  });
});

app.post("/api/v1/auth/login", (req: Request, res: Response) => {
  const { email } = req.body as { email?: string };
  const samplePayload = {
    sub: "00000000-0000-0000-0000-000000000001",
    email: email || "photographer@filmplatform.vn",
    role: "CUSTOMER" as UserRole,
  };
  const accessToken = jwt.sign(samplePayload, JWT_ACCESS_SECRET, { expiresIn: "15m" });
  res.json({
    message: "Starter login endpoint ready for FPDP-11 implementation",
    accessToken,
    user: samplePayload,
  });
});

app.get("/api/v1/users/me", (_req: Request, res: Response) => {
  res.json({
    service: "identity-service",
    rolesSupported: ["CUSTOMER", "PROVIDER", "EXPERT", "ADMIN"],
  });
});

app.listen(PORT, () => {
  console.log(`[identity-service] SOA Microservice listening on port ${PORT}`);
});
