from fastapi import FastAPI
from pydantic import BaseModel
import os

app = FastAPI()


class PredictResponse(BaseModel):
    score: float


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/predict", response_model=PredictResponse)
def predict():
    # In real use-case, this could call a model.
    # Here it's static as per assignment.
    score_env = os.getenv("PREDICT_SCORE", "0.75")
    try:
        score = float(score_env)
    except ValueError:
        score = 0.75
    return PredictResponse(score=score)
