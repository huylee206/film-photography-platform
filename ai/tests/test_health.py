from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "ok"


def test_dynamic_pricing():
    res = client.post(
        "/api/v1/ai/dynamic-pricing",
        json={"base_hourly_rate": 200000, "occupancy_ratio": 0.8},
    )
    assert res.status_code == 200
    data = res.json()
    assert data["demand_factor"] == 1.18
    assert data["suggested_hourly_rate"] == 236000.0
