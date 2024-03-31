resource "aws_iam_role" "this" {
  name = var.name
  assume_role_policy = templatefile("${path.module}/iam-trust-policy.tftpl", {
    hub_account_id = var.hub_account_id
  })
}

resource "aws_iam_policy" "this" {
  name_prefix = "${var.name}Policy"
  policy = templatefile("${path.module}/iam-role-policy.tftpl",
    {
      placeholder = "Placeholder"
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}