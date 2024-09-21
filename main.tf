
module "decision_engine_core" {
  source      = "./modules/function"
  name        = "decision-engine-core"
  description = "Decision Engine Core"
  env         = var.env
  rev         = var.rev
  source_file = "${path.module}/src/engine/main.py"
}

# module "decision_workflow" {
#   source     = "./modules/state_machine"
#   name       = "decision-workflow"
#   env        = var.env
#   rev        = var.rev
#   definition = <<EOF
#     {
#       "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
#       "StartAt": "HelloWorld",
#       "States": {
#         "HelloWorld": {
#           "Type": "Task",
#           "Resource": "minha-lambda",
#           "End": true
#         }
#       }
#     }
#   EOF
# }