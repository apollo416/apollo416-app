variable "name" {
  description = "The name of the bucket"
  type        = string
}

variable "definition" {
  description = "The definition of the state machine"
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
