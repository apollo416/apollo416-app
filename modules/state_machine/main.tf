
locals {
  machine_name = "${var.env}-${var.rev}-${var.name}-${random_pet.machine.id}"
}

resource "aws_sfn_state_machine" "main" {
  name     = local.machine_name
  role_arn = aws_iam_role.main.arn
  logging_configuration {
    level                  = "ALL"
    include_execution_data = true
    log_destination        = "${aws_cloudwatch_log_group.main.arn}:*"
  }
  tracing_configuration {
    enabled = true
  }
  definition = var.definition
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "${local.machine_name}-logs"
  retention_in_days = 365
  kms_key_id        = data.terraform_remote_state.account.outputs.kms_key_arn
  tags = {
    Env = var.env
    Rev = var.rev
  }
}

resource "aws_iam_role" "main" {
  name               = "${local.machine_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Env = var.env
    Rev = var.rev
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:states:us-east-1:${data.aws_caller_identity.current.account_id}:stateMachine:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = [
      aws_cloudwatch_log_group.main.arn
    ]
  }
}

resource "aws_iam_role_policy" "main" {
  name   = "${local.machine_name}-policy"
  role   = aws_iam_role.main.name
  policy = data.aws_iam_policy_document.policy.json
}

resource "random_pet" "machine" {
  length = 2
}
