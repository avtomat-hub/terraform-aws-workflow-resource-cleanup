resource "aws_iam_role" "this" {
  name_prefix = "schedule-${var.name}-"
  assume_role_policy = templatefile("${path.module}/iam-trust-policy.tftpl",
    {
      trust = "Trust"
  })
}

resource "aws_iam_policy" "this" {
  name_prefix = "schedule-${var.name}-"
  policy = templatefile("${path.module}/iam-role-policy.tftpl",
    {
      step_function_arn = var.step_function_arn
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}