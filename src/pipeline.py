from src.data_ingestion import main as ingest
from src.feature_engineering import main as features
from src.train import train_model


def main() -> None:
    ingest()
    features()
    train_model()


if __name__ == "__main__":
    main()
