#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_BUCKET=$(cd infra/terraform && terraform output -raw artifact_bucket)
mkdir -p /tmp/sm-model
cp models/model.joblib /tmp/sm-model/model.joblib
tar -czf /tmp/model.tar.gz -C /tmp/sm-model model.joblib
aws s3 cp /tmp/model.tar.gz "s3://$ARTIFACT_BUCKET/model/model.tar.gz"
