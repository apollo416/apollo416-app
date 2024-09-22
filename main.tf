
module "decision_engine_core" {
  source      = "./modules/function"
  name        = "decision-engine-core"
  description = "Decision Engine Core"
  env         = var.env
  rev         = var.rev
  source_file = "${path.module}/src/decision_engine_core/main.py"
}

module "decision_workflow" {
  source     = "./modules/state_machine"
  name       = "decision-workflow"
  env        = var.env
  rev        = var.rev
  definition = <<EOF
    {
      "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
      "StartAt": "HelloWorld",
      "States": {
        "HelloWorld": {
          "Type": "Task",
          "Resource": "${module.decision_engine_core.arn}",
          "End": true
        }
      }
    }
  EOF
}

module "allow_sfn_call_function" {
  source        = "./modules/allow_sfn_call_function"
  workflow_name = module.decision_workflow.name
  function_name = module.decision_engine_core.name
  function_arn  = module.decision_engine_core.arn
  sfn_role_name = module.decision_workflow.iam_role_name
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {

        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6

        properties = {
          title  = "ConcurrentExecutions"
          period = 300
          stat   = "Average"
          region = "us-east-1"
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions"]
          ]
        }
      }
    ]
  })
}