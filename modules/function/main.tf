
locals {
  function_name = "${var.env}-${var.rev}-${var.name}-${random_pet.main.id}"
}

resource "aws_lambda_function" "main" {
  function_name    = local.function_name
  description      = var.description
  role             = aws_iam_role.main.arn
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  memory_size      = 256
  timeout          = 3
  kms_key_arn      = data.terraform_remote_state.account.outputs.kms_key_arn
  handler          = "main.handler"
  runtime          = "python3.9"
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
  layers = [
    "arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:79",
    "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension:53",
    "arn:aws:lambda:us-east-1:157417159150:layer:AWSCodeGuruProfilerPythonAgentLambdaLayer:12"
  ]
  environment {
    variables = {
      AWS_CODEGURU_PROFILER_GROUP_NAME = "EngineCore"
      AWS_LAMBDA_EXEC_WRAPPER          = "/opt/codeguru_profiler_lambda_exec"

      POWERTOOLS_LOG_LEVEL    = "INFO"
      POWERTOOLS_SERVICE_NAME = var.name
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

resource "aws_iam_role_policy_attachment" "insights" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "codeguru" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCodeGuruProfilerAgentAccess"
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

resource "aws_codeguruprofiler_profiling_group" "main" {
  name             = "${local.function_name}-pg"
  compute_platform = "AWSLambda"
  agent_orchestration_config {
    profiling_enabled = true
  }
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

data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.source_file
  output_path = "bin/${local.function_name}.zip"
}