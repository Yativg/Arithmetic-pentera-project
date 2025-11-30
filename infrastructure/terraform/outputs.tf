output "jenkins_public_ip" {
  description = "Public IP address of Jenkins server"
  value       = aws_eip.jenkins_eip.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS name of Jenkins server"
  value       = aws_instance.jenkins_server.public_dns
}

output "jenkins_url" {
  description = "Jenkins web interface URL"
  value       = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}

output "ssh_connection_command" {
  description = "Command to SSH into Jenkins server"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip}"
}

output "jenkins_initial_admin_password_command" {
  description = "Command to retrieve Jenkins initial admin password"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.jenkins_server.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.jenkins_sg.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.jenkins_vpc.id
}

output "setup_instructions" {
  description = "Instructions for accessing Jenkins"
  value       = <<-EOT
    
    ========================================
    Jenkins Server Deployment Complete!
    ========================================
    
    Jenkins URL: http://${aws_eip.jenkins_eip.public_ip}:8080
    
    SSH Access: ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip}
    
    Initial Setup:
    1. Wait 5-10 minutes for Jenkins installation to complete
    2. Access Jenkins at the URL above
    3. Use the initial admin password (see command below)
    4. Complete the setup wizard
    
    Get Initial Admin Password:
    ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
    
    Check Installation Status:
    ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip} 'sudo systemctl status jenkins'
    
    View Installation Logs:
    ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip} 'sudo cat /var/log/cloud-init-output.log'
    
    ========================================
  EOT
}
