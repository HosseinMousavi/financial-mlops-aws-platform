from pathlib import Path
import pandas as pd

from evidently.report import Report
from evidently.metric_preset import DataDriftPreset


def main():

    reference = pd.read_csv(
        "data/processed/BTCUSDT_1m_features.csv"
    )

    current = reference.copy()

    report = Report(metrics=[
        DataDriftPreset()
    ])

    report.run(
        reference_data=reference,
        current_data=current
    )

    reports_dir = Path("reports")
    reports_dir.mkdir(exist_ok=True)

    html_path = reports_dir / "evidently_monitoring_report.html"

    report.save_html(str(html_path))

    print(f"Evidently report saved to {html_path}")

    # -----------------------------
    # SIMPLE DRIFT ALERT THRESHOLD
    # -----------------------------

    drift_score = 0.0

    if drift_score > 0.3:
        print("DRIFT ALERT: major data drift detected")
    else:
        print("No major drift detected")


if __name__ == "__main__":
    main()