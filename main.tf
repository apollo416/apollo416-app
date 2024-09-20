
module "test_bucket" {
  source     = "./modules/bucket"
  name       = "test-bucket"
  env        = var.env
  rev        = var.rev
  kms_key_id = data.terraform_remote_state.account.outputs.kms_key_id
}