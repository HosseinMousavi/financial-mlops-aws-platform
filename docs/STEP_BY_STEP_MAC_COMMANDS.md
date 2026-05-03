# Step-by-step Mac commands

Assumption: you run these commands in **Mac Terminal**, inside the project folder.

## 0. Install tools

```bash
brew install python@3.11 terraform awscli git docker dvc
```

Install Docker Desktop separately if needed, then open Docker Desktop before running Docker commands.

## 1. Open project

```bash
cd financial_mlops_aws_platform
```

## 2. Create virtual environment

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## 3. Create environment file

Edit this file:

```bash
cp .env.example .env
nano .env
```

Minimum local values:

```bash
MLFLOW_TRACKING_URI=http://localhost:5001
SYMBOL=BTCUSDT
INTERVAL=1m
LIMIT=1000
```

## 4. Start MLflow locally

Terminal 1:

```bash
source .venv/bin/activate
mlflow server \
  --host 0.0.0.0 \
  --port 5001 \
  --backend-store-uri sqlite:///mlflow.db \
  --default-artifact-root ./mlruns
```

Open:

```text
http://localhost:5001
```

## 5. Run the ML pipeline locally

Terminal 2:

```bash
cd financial_mlops_aws_platform
source .venv/bin/activate
python src/pipeline.py
```

Expected outputs:

```text
data/raw/BTCUSDT_1m_raw.csv
data/processed/BTCUSDT_1m_features.csv
models/model.joblib
reports/metrics.json
```

## 6. Test FastAPI inference locally

Terminal 3:

```bash
cd financial_mlops_aws_platform
source .venv/bin/activate
uvicorn serving.app:app --host 0.0.0.0 --port 8000
```

Terminal 4:

```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "return_1": 0.001,
    "return_5": 0.003,
    "volatility_10": 0.002,
    "volume_z_20": 1.2,
    "spread_proxy": 0.0008,
    "trade_intensity": 12.5,
    "taker_buy_ratio": 0.55
  }'
```

## 7. Run Evidently monitoring

```bash
source .venv/bin/activate
python monitoring/run_evidently.py
open reports/evidently_drift_report.html
```

## 8. Run with Docker Compose

```bash
docker compose -f docker-compose.local.yml up --build
```

Open:

```text
MLflow: http://localhost:5001
API:    http://localhost:8000/health
Airflow: http://localhost:8080
```

Airflow username/password:

```text
admin / admin
```

## 9. Initialize DVC

```bash
source .venv/bin/activate
dvc init
dvc repro
```

Optional S3 remote after Terraform creates buckets:

```bash
BUCKET=$(cd infra/terraform && terraform output -raw processed_bucket)
dvc remote add -d awsremote s3://$BUCKET/dvc
```

## 10. Configure AWS CLI

```bash
aws configure
```

Use your AWS access key, secret key, default region `us-east-1`, and output `json`.

Validate:

```bash
aws sts get-caller-identity
```

## 11. Terraform deploy

Edit this file:

```bash
nano infra/terraform/dev.tfvars
```

For safety, restrict this value to your IP instead of `0.0.0.0/0`:

```hcl
allowed_ingress_cidr = "YOUR_PUBLIC_IP/32"
```

Then run:

```bash
cd infra/terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

## 12. Build and push Docker images to ECR

From project root:

```bash
chmod +x scripts/*.sh
./scripts/build_and_push_ecr.sh
```

## 13. Upload model artifact for SageMaker

First train locally:

```bash
python src/pipeline.py
```

Then package/upload:

```bash
./scripts/package_sagemaker_model.sh
```

Then update/re-apply Terraform if needed:

```bash
cd infra/terraform
terraform apply -var-file=dev.tfvars
```

## 14. GitHub Actions setup

In GitHub repo secrets, add:

```text
AWS_GITHUB_ACTIONS_ROLE_ARN
```

Then run the deployment workflow manually from GitHub Actions.

## 15. Clean up AWS resources

Important to avoid charges:

```bash
cd infra/terraform
terraform destroy -var-file=dev.tfvars
```

## 16. Files to edit most often

| Purpose | File |
|---|---|
| AWS config | `infra/terraform/dev.tfvars` |
| Features | `src/feature_engineering.py` |
| Model | `src/train.py` |
| API | `serving/app.py` |
| Airflow DAG | `orchestration/airflow/dags/financial_mlops_dag.py` |
| Monitoring | `monitoring/run_evidently.py` |
| CI/CD | `.github/workflows/deploy.yml` |
