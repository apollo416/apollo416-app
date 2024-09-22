
data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      var.function_arn
    ]
  }
}

resource "aws_iam_role_policy" "main" {
  name   = "${var.workflow_name}-${var.function_name}-policy"
  role   = var.sfn_role_name
  policy = data.aws_iam_policy_document.main.json
}