from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_predict():
    response = client.get("/predict")
    assert response.status_code == 200
    data = response.json()
    assert "score" in data
    assert data["score"] == 0.75
