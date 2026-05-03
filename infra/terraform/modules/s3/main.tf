variable "name_prefix" { type = string }

locals {
  buckets = {
    raw       = "${var.name_prefix}-raw-data"
    processed = "${var.name_prefix}-processed-data"
    artifact  = "${var.name_prefix}-model-artifacts"
  }
}

resource "aws_s3_bucket" "buckets" {
  for_each = local.buckets
  bucket   = each.value
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  for_each                = aws_s3_bucket.buckets
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "raw_bucket_name" { value = aws_s3_bucket.buckets["raw"].bucket }
output "processed_bucket_name" { value = aws_s3_bucket.buckets["processed"].bucket }
output "artifact_bucket_name" { value = aws_s3_bucket.buckets["artifact"].bucket }
output "raw_bucket_arn" { value = aws_s3_bucket.buckets["raw"].arn }
output "processed_bucket_arn" { value = aws_s3_bucket.buckets["processed"].arn }
output "artifact_bucket_arn" { value = aws_s3_bucket.buckets["artifact"].arn }
