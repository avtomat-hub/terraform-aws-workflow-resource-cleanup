resource "aws_iam_role" "this" {
  name_prefix = "lambda-${var.name}-"
  assume_role_policy = templatefile("${path.module}/iam-trust-policy.tftpl", {
    lambda_service_principal = "lambda.amazonaws.com"
  })
}

resource "aws_iam_policy" "this" {
  name_prefix = "lambda-${var.name}-"
  policy = templatefile("${path.module}/iam-role-policy.tftpl",
    {
      name               = var.name
      region             = data.aws_region.current.name
      current_account_id = data.aws_caller_identity.current.account_id
      service_role_name  = var.service_role_name
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}