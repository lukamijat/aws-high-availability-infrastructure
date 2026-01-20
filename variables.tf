variable "instance_type" {
    type = string
    description = "EC2 Instance type"
    default = "t2.micro" # Replace with the instance type you desire to use
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "instance_name" {
  type = string
  default = "VM1"
}

variable "ami" {
  type = string
  default = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" # Replace with the desired AMI you want
}


variable "type_name" {
  default = "main"
}

variable "vpc_name" {
  default = "Terraform-Lern-VPC"
}

variable "availability_zones" {
  description = "List of the availability zones for the Subnets"
  type = list(string)
  default = [ "eu-central-1a", "eu-central-1b" ] # Change these to your desired region
}

variable "resource_type" {
  description = "Ressource Type for the Launch Template"
  default = "instance"
}

variable "desired_capacity" {
  description = "Desired Capacity of EC2 Instances that should run by Default"
  default = x # Replace the Number with any number of Instances you want to run
}

variable "min_size" {
  description = "The lower bound for the scaling"
  default = 1
}

variable "max_size" {
  description = "Maximum size for the scaling"
  default = 2 # Change to the number you desire
}