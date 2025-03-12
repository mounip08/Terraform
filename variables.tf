variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
variable "app_asg" {
  description = "auto scaling group"
  type	     = string
  default    = "lt-063d5ac86004626fe"
}
variable "vpc_id" {
  description = "for vpc id"
  type       = string
  default    = "vpc-06ae7c96727ba17f8"
}
variable "subnet_1_id" {
  description = "for subnet 1 id"
  type       = string  
  default    = "subnet-0739686a07685b631"
}
variable "subnet_2_id" {
  description = "for subnet 2 id"
  type       = string  
  default    = "subnet-0472fa04e525a0a69"
}
