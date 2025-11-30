terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_subnet" "jenkins_public_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Project     = var.project_name
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route_table" "jenkins_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name        = "${var.project_name}-route-table"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "jenkins_route_assoc" {
  subnet_id      = aws_subnet.jenkins_public_subnet.id
  route_table_id = aws_route_table.jenkins_route_table.id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-security-group"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  ingress {
    description = "Jenkins web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_jenkins_cidr
  }

  ingress {
    description = "Jenkins agent communication"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Arithmetic server"
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = var.allowed_app_cidr
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)

  tags = {
    Name        = "${var.project_name}-key"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.jenkins_key.key_name

  subnet_id                   = aws_subnet.jenkins_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    jenkins_admin_password = var.jenkins_admin_password
  })

  tags = {
    Name        = "${var.project_name}-server"
    Project     = var.project_name
    Environment = var.environment
  }

  provisioner "local-exec" {
    command = "echo 'Waiting for Jenkins installation to complete (this may take 5-10 minutes)...'"
  }
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_server.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-eip"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.jenkins_igw]
}
