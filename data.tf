
# locals {
#   remote_state_bucket = "apollo416-account-terraform-prd"
#   remote_state_key    = "account/terraform.tfstate"
# }

# data "terraform_remote_state" "account" {
#   backend = "s3"
#   config = {
#     bucket = local.remote_state_bucket
#     key    = local.remote_state_key
#     region = "us-east-1"
#   }
# }
