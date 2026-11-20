import cors from "cors";
import express from "express";
import helmet from "helmet";
import { env } from "./config/env";
import { apiRouter } from "./routes";

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use("/api/v1", apiRouter);

app.listen(env.port, () => {
  console.log(`[fpdp-backend] Running at http://localhost:${env.port}/api/v1`);
});
