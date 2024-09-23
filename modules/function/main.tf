
locals {
  function_name = "${var.env}-${var.rev}-${var.name}-${random_pet.main.id}"
}

resource "aws_lambda_function" "main" {
  function_name = local.function_name
  description   = var.description
  role          = aws_iam_role.main.arn
  filename      = var.file
  memory_size   = 256
  timeout       = 3
  architectures = ["arm64"]
  kms_key_arn   = data.terraform_remote_state.account.outputs.kms_key_arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  logging_config {
    log_format            = "JSON"
    system_log_level      = "DEBUG"
    application_log_level = "DEBUG"
  }
  tracing_config {
    mode = "Active"
  }
  vpc_config {
    subnet_ids         = data.terraform_remote_state.network.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.main.id]
  }
  environment {
    variables = {
      ENV = var.env
      REV = var.rev
    }
  }
  tags = {
    Env = var.env
    Rev = var.rev
  }
}

resource "aws_iam_role" "main" {
  name               = "${local.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Env = var.env
    Rev = var.rev
  }
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "main" {
  name        = "${local.function_name}-sg"
  description = "Security group for ${local.function_name}"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "${local.function_name}-sg"
    Env  = var.env
    Rev  = var.rev
  }
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  description                  = "Allow all traffic inside the security group"
  security_group_id            = aws_security_group.main.id
  referenced_security_group_id = aws_security_group.main.id
  ip_protocol                  = -1
}

resource "aws_vpc_security_group_egress_rule" "main" {
  description       = "Allow all traffic outside the security group"
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "random_pet" "main" {
  length = 2
}
