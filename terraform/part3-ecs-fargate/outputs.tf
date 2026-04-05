output "ecr_flask_url" {
  description = "ECR repository URL for Flask backend"
  value       = aws_ecr_repository.flask_repo.repository_url
}

output "ecr_express_url" {
  description = "ECR repository URL for Express frontend"
  value       = aws_ecr_repository.express_repo.repository_url
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.alb.dns_name
}

output "frontend_url" {
  description = "Express frontend URL (via ALB)"
  value       = "http://${aws_lb.alb.dns_name}"
}

output "flask_api_url" {
  description = "Flask backend API URL (via ALB)"
  value       = "http://${aws_lb.alb.dns_name}/api"
}

output "flask_health_url" {
  description = "Flask health check URL"
  value       = "http://${aws_lb.alb.dns_name}/health"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "aws_region" {
  description = "AWS region deployed to"
  value       = var.aws_region
}

output "ecr_login_command" {
  description = "Command to authenticate Docker to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
