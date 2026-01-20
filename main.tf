
provider "aws" {
  region = "eu-central-1" # Frankfurt ist super für uns
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "Terraform-Lern-VPC" }
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[0]

  tags = {
    Name = var.type_name
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.main.id

  tags = {
    Name = "Main-NAT-Gateway"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.type_name
    }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.type_name
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Subnet"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = { Name = "Public-Subnet-2"}
}

resource "aws_egress_only_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.type_name
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}
resource "aws_instance" "main" {
  
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]
  associate_public_ip_address = false
  

  tags = {
    Name = var.instance_name
  }

  user_data = file("${path.module}/userdata.sh")

}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "p" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "web_sg" {
  name = "web-server-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [ aws_security_group.alb_sg.id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "web_tg"{
  name = "web-server-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_lb_target_group_attachment" "name" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id = aws_instance.main.id
  port = 80
}

resource "aws_lb" "main" {
  name = "enterprise-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = [aws_subnet.main.id, aws_subnet.public_2.id]

  tags = {
    Name = "Main-ALB"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "enterprise-web-"
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = filebase64("${path.module}/userdata.sh")

  tag_specifications {
    resource_type = var.resource_type
    tags = {
      Name = var.instance_name
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name = "enterprise-web-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 2
  target_group_arns = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier = [aws_subnet.private.id]

  launch_template {
    id = aws_launch_template.web.id
    version = "$Latest"
  }

  health_check_type = "ELB"
  health_check_grace_period = 300
}