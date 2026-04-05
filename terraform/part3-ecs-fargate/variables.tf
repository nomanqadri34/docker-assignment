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

# ECS Task sizes (256 CPU units = 0.25 vCPU)
variable "flask_task_cpu" {
  description = "Fargate CPU units for Flask task"
  type        = number
  default     = 256
}

variable "flask_task_memory" {
  description = "Fargate memory (MiB) for Flask task"
  type        = number
  default     = 512
}

variable "express_task_cpu" {
  description = "Fargate CPU units for Express task"
  type        = number
  default     = 256
}

variable "express_task_memory" {
  description = "Fargate memory (MiB) for Express task"
  type        = number
  default     = 512
}

variable "flask_desired_count" {
  description = "Number of Flask ECS tasks to run"
  type        = number
  default     = 1
}

variable "express_desired_count" {
  description = "Number of Express ECS tasks to run"
  type        = number
  default     = 1
}
