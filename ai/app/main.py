from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(
    title="FPDP AI Service",
    version="1.0.0",
    description="Microservice AI cho gợi ý phòng tối, tìm kiếm ngữ nghĩa, RAG, khôi phục ảnh và định giá động.",
)


class RecommendRequest(BaseModel):
    user_id: str
    preferred_film_format: str = Field(default="35mm", examples=["35mm", "120", "4x5"])
    process_type: str = Field(default="BW", examples=["BW", "C41", "E6"])


class SemanticSearchRequest(BaseModel):
    query: str
    top_k: int = Field(default=5, ge=1, le=20)


class DynamicPriceRequest(BaseModel):
    base_hourly_rate: float
    occupancy_ratio: float = Field(ge=0.0, le=1.0)


@app.get("/health")
def health_check() -> dict:
    return {"status": "ok", "service": "fpdp-ai"}


@app.post("/api/v1/ai/recommend-spaces")
def recommend_spaces(payload: RecommendRequest) -> dict:
    recommendations = [
        {
            "space_id": "22222222-2222-2222-2222-222222222201",
            "name": "Phòng Tối B&W Đỏ Ilford #01",
            "score": 0.94,
            "reason": f"Phù hợp quy trình {payload.process_type} khổ {payload.preferred_film_format} với đèn safelight chuẩn.",
        }
    ]
    return {"user_id": payload.user_id, "recommendations": recommendations}


@app.post("/api/v1/ai/semantic-search")
def semantic_search(payload: SemanticSearchRequest) -> dict:
    return {
        "query": payload.query,
        "top_k": payload.top_k,
        "results": [
            {
                "article_id": "art-001",
                "title": "Hướng dẫn pha thuốc Ilford ID-11 tỷ lệ 1+1 cho phim Kodak Tri-X 400",
                "similarity": 0.91,
            }
        ],
    }


@app.post("/api/v1/ai/dynamic-pricing")
def dynamic_pricing(payload: DynamicPriceRequest) -> dict:
    # Hệ số nhu cầu từ 0.90 (giờ vắng) đến 1.25 (giờ cao điểm)
    demand_factor = round(0.90 + 0.35 * payload.occupancy_ratio, 2)
    suggested_rate = round(payload.base_hourly_rate * demand_factor, -3)
    return {
        "base_hourly_rate": payload.base_hourly_rate,
        "occupancy_ratio": payload.occupancy_ratio,
        "demand_factor": demand_factor,
        "suggested_hourly_rate": suggested_rate,
    }
