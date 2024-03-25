data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_lambda_layer_version" "this" {
  layer_name = var.layer_name
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../source/ec2-snapshots"
  output_path = "${path.module}/dist/${var.name}.zip"
}