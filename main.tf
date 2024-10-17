provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_force_path_style = true
  endpoints {
    s3 = "http://localhost:4566/"
  }
}

variable "s3_bucket_name" {
  type    = list(string)
  default = ["raw", "transformed", "staging", "enriched", "sandbox"]
}

resource "aws_s3_bucket" "bucket" {
  count  = length(var.s3_bucket_name)
  bucket = element(var.s3_bucket_name, count.index)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  count  = length(var.s3_bucket_name)
  bucket = aws_s3_bucket.bucket[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "web_app_bucket_accesp" {
  count  = length(var.s3_bucket_name)
  bucket = aws_s3_bucket.bucket[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  count  = length(var.s3_bucket_name)
  bucket = aws_s3_bucket.bucket[count.index].id

  versioning_configuration {
    status = "Enabled"
  }
}
