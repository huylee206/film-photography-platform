# backend (FPDP REST API)

**Công nghệ:** Node.js 20, TypeScript, Express, PostgreSQL (`pgvector` + `btree_gist`), Redis, MinIO.

## Cấu trúc thư mục
```text
backend/
├── src/
│   ├── config/      # Quản lý biến môi trường
│   ├── domain/      # Design Patterns (PricingStrategy, State, Composite, Observer)
│   ├── routes/      # REST API endpoints (/api/v1/*)
│   └── server.ts    # Entry point
├── package.json
└── tsconfig.json
```

## Lệnh chạy
```bash
npm install
npm run dev       # Chạy development server tại http://localhost:4000/api/v1
npm run typecheck # Kiểm tra kiểu TypeScript
npm run build     # Biên dịch ra thư mục dist/
```
