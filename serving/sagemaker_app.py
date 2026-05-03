from fastapi import FastAPI, Request, HTTPException
import joblib
import pandas as pd
from src.config import MODEL_PATH

app = FastAPI(title="SageMaker Financial Inference Container")

@app.get("/ping")
def ping():
    return {"status": "ok"}

@app.post("/invocations")
async def invocations(request: Request):
    if not MODEL_PATH.exists():
        raise HTTPException(status_code=503, detail=f"Model not found at {MODEL_PATH}")
    payload = await request.json()
    rows = payload if isinstance(payload, list) else [payload]
    bundle = joblib.load(MODEL_PATH)
    model = bundle["model"]
    features = bundle["features"]
    X = pd.DataFrame(rows)[features]
    probs = model.predict_proba(X)[:, 1]
    preds = (probs >= 0.5).astype(int)
    return {"predictions": [{"prediction": int(p), "probability_up": float(prob)} for p, prob in zip(preds, probs)]}
