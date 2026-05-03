import json
import mlflow
import mlflow.sklearn
import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, roc_auc_score, classification_report
from sklearn.model_selection import train_test_split
from src.config import DATA_PROCESSED, MODELS_DIR, REPORTS_DIR, SYMBOL, INTERVAL, MLFLOW_TRACKING_URI

FEATURES = [
    "return_1", "return_5", "volatility_10", "volume_z_20",
    "spread_proxy", "trade_intensity", "taker_buy_ratio"
]


def train_model() -> dict:
    data_path = DATA_PROCESSED / f"{SYMBOL}_{INTERVAL}_features.csv"
    df = pd.read_csv(data_path)
    X = df[FEATURES]
    y = df["target"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.25, shuffle=False
    )

    model = RandomForestClassifier(
        n_estimators=300,
        max_depth=8,
        min_samples_leaf=8,
        random_state=42,
        n_jobs=-1,
    )

    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment("financial-price-direction")

    with mlflow.start_run():
        model.fit(X_train, y_train)
        preds = model.predict(X_test)
        probs = model.predict_proba(X_test)[:, 1]
        accuracy = accuracy_score(y_test, preds)
        auc = roc_auc_score(y_test, probs)

        metrics = {"accuracy": float(accuracy), "roc_auc": float(auc)}
        mlflow.log_params(model.get_params())
        mlflow.log_metrics(metrics)
        mlflow.sklearn.log_model(model, artifact_path="model")

        model_path = MODELS_DIR / "model.joblib"
        joblib.dump({"model": model, "features": FEATURES}, model_path)

        report = classification_report(y_test, preds, output_dict=True)
        (REPORTS_DIR / "classification_report.json").write_text(json.dumps(report, indent=2))
        (REPORTS_DIR / "metrics.json").write_text(json.dumps(metrics, indent=2))
        mlflow.log_artifact(str(REPORTS_DIR / "classification_report.json"))
        mlflow.log_artifact(str(REPORTS_DIR / "metrics.json"))

    print(json.dumps(metrics, indent=2))
    return metrics


if __name__ == "__main__":
    train_model()
