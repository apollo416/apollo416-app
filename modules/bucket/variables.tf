variable "name" {
  description = "The name of the bucket"
  type        = string
}

variable "env" {
  description = "The environment for the bucket"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prd"], var.env)
    error_message = "Valid values for env are (dev, qa, prd)"
  }
}

variable "rev" {
  description = "The revision for the bucket"
  type        = string
}

variable "kms_key_id" {
  description = "The ID of the KMS key"
  type        = string
}