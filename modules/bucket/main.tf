resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
}