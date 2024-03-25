resource "aws_iam_role" "this" {
  name_prefix = "states-${var.name}-"
  assume_role_policy = templatefile("${path.module}/iam-trust-policy.tftpl",
    {
      trust = "Trust"
  })
}

resource "aws_iam_policy" "this" {
  name_prefix = "states-${var.name}-"
  policy = templatefile("${path.module}/iam-role-policy.tftpl",
    {
      region             = data.aws_region.current.name
      current_account_id = data.aws_caller_identity.current.account_id

      lambda_function_names = var.lambda_function_names
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}