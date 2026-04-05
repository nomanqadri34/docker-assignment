##############################################################
# Part 3 — Docker on AWS ECS Fargate with ECR + ALB + VPC
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
    key            = "part3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

###############################################################
# ECR REPOSITORIES
###############################################################

resource "aws_ecr_repository" "flask_repo" {
  name                 = "${var.project_name}-flask-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project_name}-flask-ecr"
    Project = var.project_name
    Part    = "3"
  }
}

resource "aws_ecr_repository" "express_repo" {
  name                 = "${var.project_name}-express-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project_name}-express-ecr"
    Project = var.project_name
    Part    = "3"
  }
}

###############################################################
# VPC & NETWORKING
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

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB — allow HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name    = "${var.project_name}-alb-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "ecs_flask_sg" {
  name        = "${var.project_name}-ecs-flask-sg"
  description = "ECS Flask tasks — accept 5000 from ALB SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ecs-flask-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "ecs_express_sg" {
  name        = "${var.project_name}-ecs-express-sg"
  description = "ECS Express tasks — accept 3000 from ALB SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ecs-express-sg"
    Project = var.project_name
  }
}

###############################################################
# IAM — ECS Task Execution Role
###############################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###############################################################
# CLOUDWATCH LOG GROUPS
###############################################################

resource "aws_cloudwatch_log_group" "flask_logs" {
  name              = "/ecs/${var.project_name}/flask-backend"
  retention_in_days = 7

  tags = {
    Project = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "express_logs" {
  name              = "/ecs/${var.project_name}/express-frontend"
  retention_in_days = 7

  tags = {
    Project = var.project_name
  }
}

###############################################################
# ECS CLUSTER
###############################################################

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = "${var.project_name}-ecs-cluster"
    Project = var.project_name
    Part    = "3"
  }
}

###############################################################
# ECS TASK DEFINITIONS
###############################################################

resource "aws_ecs_task_definition" "flask_task" {
  family                   = "${var.project_name}-flask-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.flask_task_cpu
  memory                   = var.flask_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "flask-backend"
    image     = "${aws_ecr_repository.flask_repo.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      protocol      = "tcp"
    }]

    environment = [{
      name  = "FLASK_ENV"
      value = "production"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.flask_logs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "flask"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])

  tags = {
    Project = var.project_name
  }
}

resource "aws_ecs_task_definition" "express_task" {
  family                   = "${var.project_name}-express-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.express_task_cpu
  memory                   = var.express_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "express-frontend"
    image     = "${aws_ecr_repository.express_repo.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]

    environment = [{
      name  = "FLASK_URL"
      value = "http://${aws_lb.alb.dns_name}/api"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.express_logs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "express"
      }
    }
  }])

  tags = {
    Project = var.project_name
  }
}

###############################################################
# APPLICATION LOAD BALANCER
###############################################################

resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
    Part    = "3"
  }
}

# Target group — Flask (port 5000)
resource "aws_lb_target_group" "flask_tg" {
  name        = "${var.project_name}-flask-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-flask-tg"
    Project = var.project_name
  }
}

# Target group — Express (port 3000)
resource "aws_lb_target_group" "express_tg" {
  name        = "${var.project_name}-express-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }

  tags = {
    Name    = "${var.project_name}-express-tg"
    Project = var.project_name
  }
}

# ALB Listener on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # Default: forward to Express frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.express_tg.arn
  }
}

# Listener Rule — /api/* → Flask backend
resource "aws_lb_listener_rule" "flask_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*", "/health", "/submit"]
    }
  }
}

###############################################################
# ECS SERVICES
###############################################################

resource "aws_ecs_service" "flask_service" {
  name            = "${var.project_name}-flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = var.flask_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_flask_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_tg.arn
    container_name   = "flask-backend"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_exec_attach
  ]

  tags = {
    Project = var.project_name
    Part    = "3"
  }
}

resource "aws_ecs_service" "express_service" {
  name            = "${var.project_name}-express-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.express_task.arn
  desired_count   = var.express_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_express_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express_tg.arn
    container_name   = "express-frontend"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_exec_attach
  ]

  tags = {
    Project = var.project_name
    Part    = "3"
  }
}
