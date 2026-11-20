import React, { useState } from "react";

interface SpaceItem {
  id: string;
  name: string;
  spaceType: "DARKROOM" | "STUDIO";
  dimensions: string;
  lightingSpec: string;
  ventilationSpec: string;
  hourlyRate: number;
}

const SPACES: SpaceItem[] = [
  {
    id: "22222222-2222-2222-2222-222222222201",
    name: "Phòng Tối B&W Đỏ Ilford #01",
    spaceType: "DARKROOM",
    dimensions: "4.5m x 3.2m",
    lightingSpec: "Safelight Ilford SL1 15W chống sương mù giấy",
    ventilationSpec: "Quạt hút khí hóa chất 2 chiều 350 m3/h",
    hourlyRate: 180000,
  },
  {
    id: "22222222-2222-2222-2222-222222222202",
    name: "Studio Ánh Sáng Tự Nhiên & Strobes",
    spaceType: "STUDIO",
    dimensions: "7.0m x 5.0m",
    lightingSpec: "Cửa sổ hướng Bắc + 3 đèn Profoto D2 500Ws",
    ventilationSpec: "Điều hòa Inverter 24000 BTU vận hành êm",
    hourlyRate: 320000,
  },
];

export default function App() {
  const [filter, setFilter] = useState<"ALL" | "DARKROOM" | "STUDIO">("ALL");
  const visible =
    filter === "ALL" ? SPACES : SPACES.filter((s) => s.spaceType === filter);

  return (
    <div style={{ maxWidth: 1080, margin: "0 auto", padding: "32px 20px" }}>
      <header style={{ borderBottom: "1px solid #334155", paddingBottom: 20, marginBottom: 28 }}>
        <span style={{ color: "#f59e0b", fontWeight: 700, fontSize: 13, letterSpacing: 1.2 }}>
          FILM PHOTOGRAPHY & DARKROOM PLATFORM
        </span>
        <h1 style={{ margin: "8px 0 6px", fontSize: 28 }}>
          Đặt Phòng Tối, Studio & Thiết Bị Nhiếp Ảnh Phim
        </h1>
        <p style={{ margin: 0, color: "#94a3b8" }}>
          Tìm kiếm không gian đạt chuẩn safelight, đặt kèm máy rọi, thuốc tráng và trợ lý AI.
        </p>
      </header>

      <div style={{ display: "flex", gap: 10, marginBottom: 24 }}>
        {(["ALL", "DARKROOM", "STUDIO"] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setFilter(tab)}
            style={{
              padding: "8px 16px",
              borderRadius: 8,
              border: "1px solid #475569",
              background: filter === tab ? "#f59e0b" : "#1e293b",
              color: filter === tab ? "#0f172a" : "#f8fafc",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            {tab === "ALL" ? "Tất cả không gian" : tab}
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
