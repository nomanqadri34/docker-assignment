variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "docker-assignment"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
  default     = "nomanqadri34"
}
