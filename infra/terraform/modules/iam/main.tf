variable "name_prefix" { type = string }
variable "artifact_bucket_arn" { type = string }
variable "raw_bucket_arn" { type = string }
variable "processed_bucket_arn" { type = string }

locals {
  bucket_arns = [
    var.artifact_bucket_arn,
    "${var.artifact_bucket_arn}/*",
    var.raw_bucket_arn,
    "${var.raw_bucket_arn}/*",
    var.processed_bucket_arn,
    "${var.processed_bucket_arn}/*"
  ]
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"]
    resources = local.bucket_arns
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "${var.name_prefix}-s3-access"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name_prefix}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role" "sagemaker" {
  name = "${var.name_prefix}-sagemaker-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "sagemaker.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_s3" {
  role       = aws_iam_role.sagemaker.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_ecr" {
  role       = aws_iam_role.sagemaker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ec2" {
  name = "${var.name_prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

output "ecs_task_execution_role_arn" { value = aws_iam_role.ecs_task_execution.arn }
output "ecs_task_role_arn" { value = aws_iam_role.ecs_task.arn }
output "sagemaker_execution_role_arn" { value = aws_iam_role.sagemaker.arn }
output "ec2_instance_profile_name" { value = aws_iam_instance_profile.ec2.name }
