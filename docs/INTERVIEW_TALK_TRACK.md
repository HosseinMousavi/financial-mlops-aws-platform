# Interview Talk Track

## 30-second version

I built a production-style financial ML platform for short-horizon crypto price movement prediction. The goal was not just model accuracy but full system maturity: Terraform-provisioned AWS infrastructure, Dockerized training and inference, Airflow orchestration, MLflow tracking, DVC versioning, Evidently monitoring, and GitHub Actions CI/CD.

## Why this project matters

Most ML projects stop at notebooks. This one covers the production lifecycle:

1. data ingestion
2. feature engineering
3. experiment tracking
4. model training
5. model serving
6. monitoring
7. infrastructure automation
8. CI/CD

## Why financial data

Financial market data is noisy, high-frequency, and drift-prone. That makes it ideal for demonstrating real MLOps because model performance degrades quickly and monitoring matters.

## Design choice: ECS and SageMaker

I included both:

- ECS for general containerized FastAPI inference
- SageMaker for managed ML endpoint deployment

In production, I would choose one based on cost, latency, governance, and team requirements.

## Production improvements I would add next

- private subnets + NAT gateway
- Application Load Balancer with HTTPS
- Secrets Manager
- SageMaker Model Registry
- scheduled retraining from EventBridge
- feature store
- canary deployment
- Prometheus/Grafana or CloudWatch dashboards
