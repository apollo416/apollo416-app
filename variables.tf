
variable "env" {
  description = "The environment for the app"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prd"], var.env)
    error_message = "Valid values for env are (dev, qa, prd)"
  }
}

variable "rev" {
  description = "The revision for the app"
  type        = string
}
