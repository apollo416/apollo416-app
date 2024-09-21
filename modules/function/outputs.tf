
output "name" {
  description = "Name of the function"
  value       = aws_lambda_function.main.function_name
}

output "arn" {
  description = "The arn of the function"
  value       = aws_lambda_function.main.arn
}
