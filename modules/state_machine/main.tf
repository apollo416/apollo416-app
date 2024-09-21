
locals {
  machine_name = "${var.env}-${var.rev}-${var.name}-${random_pet.machine.id}"
}

resource "aws_sfn_state_machine" "main" {
  name     = local.machine_name
  role_arn = aws_iam_role.main.arn
  logging_configuration {
    level                  = "ALL"
    include_execution_data = true
  }
  tracing_configuration {
    enabled = true
  }
  definition = var.definition
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

resource "random_pet" "machine" {
  length = 2
}
