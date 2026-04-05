variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
  default     = "docker-assignment"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "docker-assignment-key"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_a" {
  description = "Public subnet A CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_b" {
  description = "Public subnet B CIDR"
  type        = string
  default     = "10.0.2.0/24"
}
