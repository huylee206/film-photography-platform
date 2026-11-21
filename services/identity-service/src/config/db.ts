import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config();

export const pool = new Pool({
  connectionString:
    process.env.DATABASE_URL ||
    "postgresql://film_admin:film_secret_2026@localhost:5432/film_platform",
});

pool.on("connect", (client) => {
  client.query("SET search_path TO identity, public;").catch(() => {});
});
