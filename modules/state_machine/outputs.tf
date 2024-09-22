
output "name" {
  description = "The name of the machine"
  value       = aws_sfn_state_machine.main.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.main.arn
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.main.name
}