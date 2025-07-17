output "asg_name" {
  value = aws_autoscaling_group.asg_group.name
}

output "asg_arn" {
  value = aws_autoscaling_group.asg_group.arn
}

output "key_pair_public_key" {
  description = "The generated Public Key for the EC2 server."
  value       = try(aws_key_pair.generated_key[0].public_key, null)
  sensitive   = true
}

output "pem" {
  description = "The generated Private Key PEM for the EC2 server."
  value       = try(tls_private_key.ec2_key[0].private_key_pem, null)
  sensitive   = true
}