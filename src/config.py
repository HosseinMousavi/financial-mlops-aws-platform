from pathlib import Path
import os
from dotenv import load_dotenv

load_dotenv()

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_RAW = PROJECT_ROOT / "data" / "raw"
DATA_PROCESSED = PROJECT_ROOT / "data" / "processed"
MODELS_DIR = PROJECT_ROOT / "models"
REPORTS_DIR = PROJECT_ROOT / "reports"

SYMBOL = os.getenv("SYMBOL", "BTCUSDT")
INTERVAL = os.getenv("INTERVAL", "1m")
LIMIT = int(os.getenv("LIMIT", "1000"))
MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5001")
MODEL_PATH = Path(os.getenv("MODEL_PATH", str(MODELS_DIR / "model.joblib")))

for p in [DATA_RAW, DATA_PROCESSED, MODELS_DIR, REPORTS_DIR]:
    p.mkdir(parents=True, exist_ok=True)
