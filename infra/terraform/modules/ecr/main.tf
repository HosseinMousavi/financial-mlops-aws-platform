variable "name_prefix" { type = string }

resource "aws_ecr_repository" "api" {
  name                 = "${var.name_prefix}-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}

resource "aws_ecr_repository" "train" {
  name                 = "${var.name_prefix}-train"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}

resource "aws_ecr_repository" "sagemaker" {
  name                 = "${var.name_prefix}-sagemaker"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}

output "api_repository_url" { value = aws_ecr_repository.api.repository_url }
output "train_repository_url" { value = aws_ecr_repository.train.repository_url }
output "sagemaker_repository_url" { value = aws_ecr_repository.sagemaker.repository_url }
