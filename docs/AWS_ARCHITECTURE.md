# AWS Architecture

```mermaid
flowchart LR
    A[Binance Market Data API] --> B[Airflow DAG]
    B --> C[Dockerized Ingestion + Feature Engineering]
    C --> D[(S3 Raw + Processed Data)]
    C --> E[DVC Versioning]
    B --> F[Dockerized Training Job]
    F --> G[MLflow Tracking]
    F --> H[(S3 Model Artifacts)]
    F --> I[Evidently Drift Report]
    I --> J[CloudWatch Logs + Alarms]

    K[Terraform] --> L[AWS VPC + IAM]
    K --> D
    K --> M[ECR Repositories]
    K --> N[ECS Fargate FastAPI Service]
    K --> O[SageMaker Endpoint]
    K --> P[EC2 Ops Host]
    K --> J

    M --> N
    H --> O
    N --> Q[REST /predict]
    O --> R[SageMaker Real-time Inference]

    S[GitHub Actions] --> T[Terraform Validate/Apply]
    S --> U[Docker Build + Push to ECR]
```

## Components

| Layer | Tool | Purpose |
|---|---|---|
| Infrastructure | Terraform | Reproducible AWS infra provisioning |
| Storage | S3 | Raw data, processed data, model artifacts |
| Container Registry | ECR | Store training and inference Docker images |
| Compute | ECS Fargate | Host FastAPI inference service |
| ML Deployment | SageMaker | Real-time model endpoint pattern |
| Ops Host | EC2 | Lightweight dev/ops server for experiments |
| Orchestration | Airflow | Schedule ingestion, features, training, monitoring |
| Experiment Tracking | MLflow | Params, metrics, model artifacts |
| Versioning | DVC | Data/model pipeline reproducibility |
| Monitoring | Evidently + CloudWatch | Drift reports, logs, alarms |
| CI/CD | GitHub Actions | Build, validate, deploy |

## Notes

This project intentionally includes both ECS and SageMaker:

- ECS shows general containerized production API deployment.
- SageMaker shows ML-native managed endpoint deployment.

In an interview, explain that a real company would usually choose one primary serving path depending on latency, cost, compliance, and team maturity.
