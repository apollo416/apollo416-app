
# data "aws_caller_identity" "current" {}

locals {
  account_remote_state_key    = "account/terraform.tfstate"
  account_remote_state_bucket = "apollo416-account-terraform-prd"
  network_remote_state_key    = "${var.env}/network/terraform.tfstate"
  network_remote_state_bucket = "apollo416-terraform-infra-state-${var.env}"
}

data "terraform_remote_state" "account" {
  backend = "s3"
  config = {
    key    = local.account_remote_state_key
    bucket = local.account_remote_state_bucket
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    key    = local.network_remote_state_key
    bucket = local.network_remote_state_bucket
    region = "us-east-1"
  }
}