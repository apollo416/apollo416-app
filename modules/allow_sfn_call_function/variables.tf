
variable "workflow_name" {
  description = "The name of the state machine"
  type        = string
}

variable "function_name" {
  description = "The name of the function to allow the state machine to call"
  type        = string

}

variable "function_arn" {
  description = "The ARN of the function to allow the state machine to call"
  type        = string
}

variable "sfn_role_name" {
  description = "The name of the role to attach the policy to"
  type        = string
}