output "ec2_public_ips" {
  value       = [aws_instance.ec2_1.public_ip, aws_instance.ec2_2.public_ip]
  description = "Public IPs of EC2 instances"
}

# output "alb_dns_name" {
#   value       = aws_lb.capstone_alb.dns_name
#   description = "DNS name of the Application Load Balancer"
# }

output "ecr_repository_urls" {
  value       = aws_ecr_repository.capstone-repo.repository_url
  description = "ECR repository URLs"
}
