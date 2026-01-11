variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "public_key" {
  description = "SSH public key content from GitHub Secret"
  type        = string
  default = "Terraform-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name for the key pair"
  type        = string
  default     = "Terraform-key"
}

