##############################################################
# Part 2 — Flask on one EC2, Express on a SEPARATE EC2
#           Custom VPC, subnets, and security groups
##############################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "docker-assignment-tfstate"
    key            = "part2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

# ── Latest Ubuntu 22.04 AMI ───────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

###############################################################
# NETWORKING
###############################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_a
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-a"
    Project = var.project_name
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_b
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-b"
    Project = var.project_name
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "rta_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rta_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

###############################################################
# SECURITY GROUPS
###############################################################

# Flask Backend SG — accepts 5000 from Express SG + SSH from anywhere
resource "aws_security_group" "flask_sg" {
  name        = "${var.project_name}-flask-sg"
  description = "Flask backend security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Flask from Express SG"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.express_sg.id]
  }

  # Also expose to internet for demo/testing
  ingress {
    description = "Flask from internet (demo)"
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
    Name    = "${var.project_name}-flask-sg"
    Project = var.project_name
  }
}

# Express Frontend SG — accepts 3000 from internet
resource "aws_security_group" "express_sg" {
  name        = "${var.project_name}-express-sg"
  description = "Express frontend security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Express from internet"
    from_port   = 3000
    to_port     = 3000
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
    Name    = "${var.project_name}-express-sg"
    Project = var.project_name
  }
}

###############################################################
# EC2 — FLASK BACKEND
###############################################################

resource "aws_instance" "flask_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data = base64encode(file("${path.module}/flask_userdata.sh"))

  tags = {
    Name    = "${var.project_name}-flask-ec2"
    Project = var.project_name
    Part    = "2"
    Role    = "backend"
  }
}

###############################################################
# EC2 — EXPRESS FRONTEND
###############################################################

resource "aws_instance" "express_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.express_sg.id]

  # Pass the Flask private IP so Express can reach it
  user_data = base64encode(templatefile("${path.module}/express_userdata.sh", {
    flask_private_ip = aws_instance.flask_ec2.private_ip
    flask_port       = 5000
  }))

  # Express depends on Flask being up first
  depends_on = [aws_instance.flask_ec2]

  tags = {
    Name    = "${var.project_name}-express-ec2"
    Project = var.project_name
    Part    = "2"
    Role    = "frontend"
  }
}
