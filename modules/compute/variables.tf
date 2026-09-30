variable "security_group" {
  description = "Security group for the EC2 instance"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EC2 instance"
  type        = list(string)
}