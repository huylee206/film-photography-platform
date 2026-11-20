import dotenv from "dotenv";

dotenv.config({ path: "../.env" });
dotenv.config();

export const env = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: Number(process.env.APP_PORT || 4000),
  databaseUrl:
    process.env.DATABASE_URL ||
    "postgresql://film:change_me@localhost:5432/film_platform",
  redisUrl: process.env.REDIS_URL || "redis://localhost:6379",
  aiServiceUrl: process.env.AI_SERVICE_URL || "http://localhost:8000",
  jwtSecret: process.env.JWT_SECRET || "super_secret_jwt_key_change_in_production",
};
