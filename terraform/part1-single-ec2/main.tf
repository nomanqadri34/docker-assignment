##############################################################
# Part 1 — Both Flask (port 5000) and Express (port 3000)
#           on a SINGLE EC2 instance
##############################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── S3 Remote State ──────────────────────────────────────
  backend "s3" {
    bucket         = "docker-assignment-tfstate"
    key            = "part1/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

# ── Data sources ─────────────────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Security Group ────────────────────────────────────────────
resource "aws_security_group" "single_ec2_sg" {
  name        = "${var.project_name}-single-ec2-sg"
  description = "Allow HTTP on 3000 & 5000 plus SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Express Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-single-ec2-sg"
    Project = var.project_name
  }
}

# ── EC2 Instance ──────────────────────────────────────────────
resource "aws_instance" "single_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.single_ec2_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    flask_port  = 5000
    express_port = 3000
  }))

  tags = {
    Name    = "${var.project_name}-single-ec2"
    Project = var.project_name
    Part    = "1"
  }
}
