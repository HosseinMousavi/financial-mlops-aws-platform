import pandas as pd
import numpy as np
from src.config import DATA_RAW, DATA_PROCESSED, SYMBOL, INTERVAL


def make_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.sort_values("open_time").copy()
    df["return_1"] = df["close"].pct_change()
    df["return_5"] = df["close"].pct_change(5)
    df["volatility_10"] = df["return_1"].rolling(10).std()
    df["volume_z_20"] = (df["volume"] - df["volume"].rolling(20).mean()) / df["volume"].rolling(20).std()
    df["spread_proxy"] = (df["high"] - df["low"]) / df["close"]
    df["trade_intensity"] = df["num_trades"] / (df["volume"] + 1e-9)
    df["taker_buy_ratio"] = df["taker_buy_base_volume"] / (df["volume"] + 1e-9)
    df["future_return_5"] = df["close"].shift(-5) / df["close"] - 1
    df["target"] = (df["future_return_5"] > 0).astype(int)
    return df.dropna().reset_index(drop=True)


def main() -> None:
    raw_path = DATA_RAW / f"{SYMBOL}_{INTERVAL}_raw.csv"
    df = pd.read_csv(raw_path, parse_dates=["open_time", "close_time"])
    features = make_features(df)
    out = DATA_PROCESSED / f"{SYMBOL}_{INTERVAL}_features.csv"
    features.to_csv(out, index=False)
    print(f"Saved features to {out}")


if __name__ == "__main__":
    main()
