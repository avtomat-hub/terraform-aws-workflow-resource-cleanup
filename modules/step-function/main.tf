resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = aws_iam_role.this.arn
  definition = templatefile("${path.module}/step-function-definition.tftpl",
    {
      name               = var.name
      region             = data.aws_region.current.name
      current_account_id = data.aws_caller_identity.current.account_id

      lambda_function_names = var.lambda_function_names
  })
}