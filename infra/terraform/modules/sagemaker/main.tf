variable "name_prefix" { type = string }
variable "model_image" { type = string }
variable "execution_role_arn" { type = string }
variable "artifact_bucket" { type = string }

resource "aws_sagemaker_model" "this" {
  name               = "${var.name_prefix}-model"
  execution_role_arn = var.execution_role_arn

  primary_container {
    image          = var.model_image
    model_data_url = "s3://${var.artifact_bucket}/model/model.tar.gz"
    environment = {
      SAGEMAKER_PROGRAM = "serving/app.py"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "this" {
  name = "${var.name_prefix}-endpoint-config"

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.this.name
    initial_instance_count = 1
    instance_type          = "ml.m5.large"
  }
}

resource "aws_sagemaker_endpoint" "this" {
  name                 = "${var.name_prefix}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.this.name
}

output "endpoint_name" { value = aws_sagemaker_endpoint.this.name }
