
output "name" {
  description = "The name of the machine"
  value       = aws_sfn_state_machine.main.name
}

