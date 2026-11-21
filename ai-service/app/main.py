from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(
    title="Film Photography Platform - AI Microservice",
    version="1.0.0",
    description="SOA AI Service providing Semantic Search, Film Recipe RAG, Photo Restoration & Dynamic Pricing",
)


class SemanticSearchRequest(BaseModel):
    query: str
    top_k: int = 5


@app.get("/health")
def health_check():
    return {
        "service": "ai-service",
        "framework": "FastAPI",
        "port": 8000,
        "capabilities": [
            "semantic-space-search",
            "film-recipe-rag",
            "negative-restoration",
            "dynamic-pricing",
            "gear-compatibility",
            "chemical-defect-diagnosis",
            "demand-forecast",
        ],
    }


@app.post("/api/v1/ai/semantic-search")
def semantic_search(payload: SemanticSearchRequest):
    return {
        "service": "ai-service",
        "query": payload.query,
        "top_k": payload.top_k,
        "results": [],
    }
