output "ec2_public_ip" {
  description = "EC2's Public IP"
  value       = aws_instance.my_terraform_ec2.public_ip
}
