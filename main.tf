provider "aws" {
  region = "us-west-2"
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check = true
  s3_force_path_style = true
  endpoints {
    s3 = "http://172.19.0.1:4566"
  }
}

variable "s3_bucket_name" {
  type    = list(string)
  default = ["raw", "transformed", "staging", "enriched", "sandbox"]
}

resource "aws_s3_bucket" "bucket" {
  count         = "${length(var.s3_bucket_name)}"
  bucket        = "${element(var.s3_bucket_name, count.index)}"
  acl           = "private"
  force_destroy = "true"
    lifecycle_rule {
    enabled = true

    transition {
      days = 180
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 360
      storage_class = "GLACIER"
    }
  }
}
