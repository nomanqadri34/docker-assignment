output "flask_public_ip" {
  description = "Flask backend public IP"
  value       = aws_instance.flask_ec2.public_ip
}

output "flask_private_ip" {
  description = "Flask backend private IP (used by Express)"
  value       = aws_instance.flask_ec2.private_ip
}

output "express_public_ip" {
  description = "Express frontend public IP"
  value       = aws_instance.express_ec2.public_ip
}

output "flask_url" {
  description = "Flask backend URL (public internet)"
  value       = "http://${aws_instance.flask_ec2.public_ip}:5000"
}

output "express_url" {
  description = "Express frontend URL"
  value       = "http://${aws_instance.express_ec2.public_ip}:3000"
}

output "flask_health_check" {
  description = "Flask health endpoint"
  value       = "http://${aws_instance.flask_ec2.public_ip}:5000/health"
}

output "ssh_flask" {
  description = "SSH into Flask instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.flask_ec2.public_ip}"
}

output "ssh_express" {
  description = "SSH into Express instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.express_ec2.public_ip}"
}
