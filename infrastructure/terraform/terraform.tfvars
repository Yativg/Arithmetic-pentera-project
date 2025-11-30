aws_region = "us-east-1"

project_name = "pentera-jenkins"
environment  = "dev"

vpc_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

instance_type     = "t3.micro"
root_volume_size  = 20

allowed_ssh_cidr     = ["0.0.0.0/0"]
allowed_jenkins_cidr = ["0.0.0.0/0"]
allowed_app_cidr     = ["0.0.0.0/0"]

ssh_public_key_path = "~/.ssh/id_rsa.pub"

jenkins_admin_password = "CHANGE_ME_OR_USE_ENV_VAR"
