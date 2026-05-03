import requests
import pandas as pd
from src.config import DATA_RAW, SYMBOL, INTERVAL, LIMIT

BINANCE_KLINES_URL = "https://api.binance.com/api/v3/klines"
COINBASE_CANDLES_URL = "https://api.exchange.coinbase.com/products/{product_id}/candles"


def _coinbase_product_id(symbol: str) -> str:
    if symbol.upper() == "BTCUSDT":
        return "BTC-USD"
    if symbol.upper().endswith("USDT"):
        return symbol.upper().replace("USDT", "-USD")
    return symbol.upper()


def _interval_to_granularity(interval: str) -> int:
    mapping = {
        "1m": 60,
        "5m": 300,
        "15m": 900,
        "1h": 3600,
        "6h": 21600,
        "1d": 86400,
    }
    return mapping.get(interval, 60)


def fetch_klines(symbol: str = SYMBOL, interval: str = INTERVAL, limit: int = LIMIT) -> pd.DataFrame:
    params = {"symbol": symbol, "interval": interval, "limit": limit}
    response = requests.get(BINANCE_KLINES_URL, params=params, timeout=30)
    response.raise_for_status()

    rows = response.json()
    cols = [
        "open_time", "open", "high", "low", "close", "volume",
        "close_time", "quote_asset_volume", "num_trades",
        "taker_buy_base_volume", "taker_buy_quote_volume", "ignore"
    ]

    df = pd.DataFrame(rows, columns=cols)
    numeric_cols = [
        "open", "high", "low", "close", "volume",
        "quote_asset_volume", "num_trades",
        "taker_buy_base_volume", "taker_buy_quote_volume"
    ]
    df[numeric_cols] = df[numeric_cols].astype(float)
    df["open_time"] = pd.to_datetime(df["open_time"], unit="ms", utc=True)
    df["close_time"] = pd.to_datetime(df["close_time"], unit="ms", utc=True)

    return df.drop(columns=["ignore"])


def fetch_coinbase_candles(symbol: str = SYMBOL, interval: str = INTERVAL, limit: int = LIMIT) -> pd.DataFrame:
    product_id = _coinbase_product_id(symbol)
    granularity = _interval_to_granularity(interval)
    url = COINBASE_CANDLES_URL.format(product_id=product_id)

    params = {"granularity": granularity}
    headers = {"User-Agent": "financial-mlops-platform/1.0"}

    response = requests.get(url, params=params, headers=headers, timeout=30)
    response.raise_for_status()

    rows = response.json()
    if not rows:
        raise ValueError("Coinbase returned no candle data.")

    cols = ["time", "low", "high", "open", "close", "volume"]
    df = pd.DataFrame(rows, columns=cols)
    df = df.sort_values("time").tail(limit).reset_index(drop=True)

    df["open_time"] = pd.to_datetime(df["time"], unit="s", utc=True)
    df["close_time"] = df["open_time"] + pd.to_timedelta(granularity, unit="s")
    df["quote_asset_volume"] = df["close"] * df["volume"]
    df["num_trades"] = 0.0
    df["taker_buy_base_volume"] = df["volume"] * 0.5
    df["taker_buy_quote_volume"] = df["quote_asset_volume"] * 0.5

    ordered_cols = [
        "open_time", "open", "high", "low", "close", "volume",
        "close_time", "quote_asset_volume", "num_trades",
        "taker_buy_base_volume", "taker_buy_quote_volume"
    ]

    return df[ordered_cols]


def main() -> None:
    DATA_RAW.mkdir(parents=True, exist_ok=True)

    try:
        df = fetch_klines()
        source = "binance"
    except requests.exceptions.HTTPError as exc:
        status_code = exc.response.status_code if exc.response is not None else "unknown"
        print(f"Binance request failed with status {status_code}. Falling back to Coinbase.")
        df = fetch_coinbase_candles()
        source = "coinbase"

    out = DATA_RAW / f"{SYMBOL}_{INTERVAL}_raw.csv"
    df.to_csv(out, index=False)
    print(f"Saved {source} raw data to {out}")


if __name__ == "__main__":
    main()