variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "pentera-jenkins"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH to Jenkins server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_jenkins_cidr" {
  description = "CIDR blocks allowed to access Jenkins web UI"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_app_cidr" {
  description = "CIDR blocks allowed to access the arithmetic application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_public_key" {
  description = "SSH public key content (if provided directly)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "jenkins_admin_password" {
  description = "Initial admin password for Jenkins"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}
