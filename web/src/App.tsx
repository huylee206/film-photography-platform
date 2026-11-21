import { useEffect, useState } from "react";

interface CreativeSpace {
  id: string;
  name: string;
  spaceType: "DARKROOM" | "ANALOG_STUDIO" | "HYBRID_LAB";
  hourlyRate: number;
  dimensions: string;
  lightingSpec: string;
  ventilationSpec: string;
}

const FALLBACK_SPACES: CreativeSpace[] = [
  {
    id: "sp-01",
    name: "Saigon Silver Halide Darkroom #1",
    spaceType: "DARKROOM",
    hourlyRate: 180000,
    dimensions: "4.5m x 3.2m (Tối đa 3 người)",
    lightingSpec: "Đèn đỏ safelight Ilford SL1 + Đèn rọi Beseler 23CIII",
    ventilationSpec: "Quạt hút công nghiệp 2 chiều khử mùi hóa chất",
  },
  {
    id: "sp-02",
    name: "ChoLon Medium Format Analog Studio",
    spaceType: "ANALOG_STUDIO",
    hourlyRate: 320000,
    dimensions: "6.0m x 5.0m (Trần cao 3.8m)",
    lightingSpec: "Profoto D2 500Ws + Phông giấy vô cực + Ánh sáng tự nhiên",
    ventilationSpec: "Điều hòa Inverter 2HP + Lọc không khí HEPA",
  },
  {
    id: "sp-03",
    name: "Kodak C-41 & ECN-2 Hybrid Processing Lab",
    spaceType: "HYBRID_LAB",
    hourlyRate: 250000,
    dimensions: "5.0m x 4.0m",
    lightingSpec: "Bàn soi phim chuẩn CRI 98+ 5000K + Máy scan Noritsu",
    ventilationSpec: "Tủ hút khí độc chuyên dụng cho hóa chất tráng màu",
  },
];

const MICROSERVICES = [
  { name: "API Gateway (Nginx)", port: ":4000", status: "Active" },
  { name: "Identity Service", port: ":4001", status: "Active" },
  { name: "Catalog & Booking Service", port: ":4002", status: "Active" },
  { name: "Community Service", port: ":4003", status: "Active" },
  { name: "AI Service (FastAPI)", port: ":8000", status: "Active" },
];

export default function App() {
  const [spaces, setSpaces] = useState<CreativeSpace[]>(FALLBACK_SPACES);
  const [filter, setFilter] = useState<string>("ALL");

  useEffect(() => {
    const baseUrl = import.meta.env.VITE_API_BASE_URL || "http://localhost:4000/api/v1";
    fetch(`${baseUrl}/spaces`)
      .then((res) => res.json())
      .then((json) => {
        if (Array.isArray(json.data) && json.data.length > 0) {
          setSpaces(json.data);
        }
      })
      .catch(() => {
        // Use fallback seed data when API Gateway is offline
      });
  }, []);

  const visible = filter === "ALL" ? spaces : spaces.filter((s) => s.spaceType === filter);

  return (
    <div style={{ maxWidth: 1120, margin: "0 auto", padding: "32px 20px" }}>
      <header style={{ marginBottom: 28 }}>
        <span
          style={{
            background: "#1e293b",
            border: "1px solid #38bdf8",
            color: "#38bdf8",
            padding: "4px 12px",
            borderRadius: 999,
            fontSize: 12,
            fontWeight: 700,
          }}
        >
          SOA & MICROSERVICES ARCHITECTURE
        </span>
        <h1 style={{ margin: "12px 0 8px", fontSize: 30 }}>
          Film Photography Creative Space & Analog Lab Platform
        </h1>
        <p style={{ margin: 0, color: "#94a3b8" }}>
          Hệ sinh thái đặt phòng tối (Darkroom), studio phim chuyên dụng, thuê thiết bị & cộng đồng nhiếp ảnh phim.
        </p>
      </header>

      <section
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(190px, 1fr))",
          gap: 12,
          marginBottom: 28,
        }}
      >
        {MICROSERVICES.map((svc) => (
          <div
            key={svc.name}
            style={{
              background: "#1e293b",
              border: "1px solid #334155",
              borderRadius: 10,
              padding: "12px 14px",
            }}
          >
            <div style={{ fontSize: 13, fontWeight: 700, color: "#e2e8f0" }}>{svc.name}</div>
            <div style={{ display: "flex", justifyContent: "space-between", marginTop: 6, fontSize: 12 }}>
              <span style={{ color: "#38bdf8" }}>{svc.port}</span>
              <span style={{ color: "#4ade80" }}>● {svc.status}</span>
            </div>
          </div>
        ))}
      </section>

      <div style={{ display: "flex", gap: 10, marginBottom: 20, flexWrap: "wrap" }}>
        {["ALL", "DARKROOM", "ANALOG_STUDIO", "HYBRID_LAB"].map((tab) => (
          <button
            key={tab}
            onClick={() => setFilter(tab)}
            style={{
              padding: "8px 16px",
              borderRadius: 8,
              border: "1px solid #334155",
              background: filter === tab ? "#f59e0b" : "#1e293b",
              color: filter === tab ? "#0f172a" : "#f8fafc",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            {tab}
          </button>
        ))}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))", gap: 20 }}>
        {visible.map((space) => (
          <div
            key={space.id}
            style={{
              background: "#1e293b",
              border: "1px solid #334155",
              borderRadius: 12,
              padding: 20,
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span
                style={{
                  background: space.spaceType === "DARKROOM" ? "#7f1d1d" : "#1e3a8a",
                  color: "#fecaca",
                  padding: "3px 10px",
                  borderRadius: 999,
                  fontSize: 12,
                  fontWeight: 700,
                }}
              >
                {space.spaceType}
              </span>
              <strong style={{ color: "#fbbf24" }}>
                {space.hourlyRate.toLocaleString("vi-VN")} đ/giờ
              </strong>
            </div>
            <h3 style={{ margin: "12px 0 8px" }}>{space.name}</h3>
            <ul style={{ paddingLeft: 18, color: "#cbd5e1", fontSize: 14, lineHeight: 1.6 }}>
              <li>Kích thước: {space.dimensions}</li>
              <li>Ánh sáng: {space.lightingSpec}</li>
              <li>Thông gió: {space.ventilationSpec}</li>
            </ul>
          </div>
        ))}
      </div>
    </div>
  );
}
