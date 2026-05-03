PYTHON=python3

setup:
	$(PYTHON) -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

train:
	. .venv/bin/activate && python src/train.py

serve:
	. .venv/bin/activate && uvicorn serving.app:app --host 0.0.0.0 --port 8000

monitor:
	. .venv/bin/activate && python monitoring/run_evidently.py

dvc-init:
	. .venv/bin/activate && dvc init

dvc-run:
	. .venv/bin/activate && dvc repro

local-stack:
	docker compose -f docker-compose.local.yml up --build

terraform-init:
	cd infra/terraform && terraform init

terraform-plan:
	cd infra/terraform && terraform plan -var-file=dev.tfvars

terraform-apply:
	cd infra/terraform && terraform apply -var-file=dev.tfvars

terraform-destroy:
	cd infra/terraform && terraform destroy -var-file=dev.tfvars
