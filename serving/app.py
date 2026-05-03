import os
import joblib
import mlflow
import mlflow.sklearn
import pandas as pd
from fastapi import FastAPI
from pydantic import BaseModel
from mlflow.tracking import MlflowClient

app = FastAPI(title="Financial ML Inference API")

MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://127.0.0.1:5001")
EXPERIMENT_NAME = "financial-price-direction"
LOCAL_MODEL_PATH = "models/model.joblib"

FEATURES = [
    "return_1",
    "return_5",
    "volatility_10",
    "volume_z_20",
    "spread_proxy",
    "trade_intensity",
    "taker_buy_ratio",
]

model = None


class PredictionRequest(BaseModel):
    return_1: float
    return_5: float
    volatility_10: float
    volume_z_20: float
    spread_proxy: float
    trade_intensity: float
    taker_buy_ratio: float


def load_latest_model_from_mlflow():
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    client = MlflowClient(tracking_uri=MLFLOW_TRACKING_URI)

    experiment = client.get_experiment_by_name(EXPERIMENT_NAME)
    if experiment is None:
        raise RuntimeError(f"Experiment not found: {EXPERIMENT_NAME}")

    runs = client.search_runs(
        experiment_ids=[experiment.experiment_id],
        order_by=["attributes.start_time DESC"],
        max_results=1,
    )

    if not runs:
        raise RuntimeError("No MLflow runs found.")

    run_id = runs[0].info.run_id
    model_uri = f"runs:/{run_id}/model"

    return mlflow.sklearn.load_model(model_uri)


def load_model():
    try:
        print("Loading model from MLflow...")
        return load_latest_model_from_mlflow()
    except Exception as exc:
        print(f"MLflow model load failed: {exc}")
        print("Falling back to local model.joblib...")

        bundle = joblib.load(LOCAL_MODEL_PATH)
        return bundle["model"]


@app.on_event("startup")
def startup_event():
    global model
    model = load_model()
    print("Model loaded successfully.")


@app.get("/")
def root():
    return {"status": "running", "model_source": "mlflow_or_local_fallback"}


@app.get("/health")
def health():
    return {"status": "healthy", "model_loaded": model is not None}


@app.post("/predict")
def predict(request: PredictionRequest):
    input_df = pd.DataFrame([request.model_dump()])[FEATURES]
    prediction = int(model.predict(input_df)[0])
    probability = float(model.predict_proba(input_df)[0][1])

    return {
        "prediction": prediction,
        "probability_up": probability,
    }