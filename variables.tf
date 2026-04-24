variable "ec2_name" {
  description = "Name of the AWS EC2 instance"
  type        = string
  default     = "my_terraform_ec2"
}

variable "ec2_type" {
  description = "Type of the AWS EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ssh_key" {
  description = "AWS EC2 instance SSH key pair"
  type        = string
  default     = "ec2_key_pair"
}
