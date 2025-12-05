from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class PredictResponse(BaseModel):
    score: float


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/predict", response_model=PredictResponse)
def predict():
    # static score as per assignment
    return {"score": 0.75}
