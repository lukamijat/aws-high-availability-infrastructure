output "instance_public_ip" {
  description = "Public IP-Address of the Server"
  value = aws_instance.main.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value = aws_instance.main.id
}

output "alb_" {
  description = "Public URL of the Load Balancer"
  value = aws_lb.main.dns_name
}