resource "aws_lambda_function" "this" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.this.arn
  function_name    = var.name
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  description      = var.description
  architectures    = [var.architectures]
  layers           = [data.aws_lambda_layer_version.this.arn]

  environment {
    variables = {
      SERVICE_ROLE_NAME = var.service_role_name
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.cloudwatch_log_retention_in_days
}