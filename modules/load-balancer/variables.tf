variable "security_group" {
  description = "Security group for the EC2 instance"
  type        = any
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EC2 instance"
  type        = list(string)
}

variable "instance_id" {
  description = "ID of the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}