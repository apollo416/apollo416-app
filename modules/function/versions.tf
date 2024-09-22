
terraform {
  required_version = "1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.6.0"
    }
  }
}
