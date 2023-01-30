output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2-instance.id
}

output "id" {
  description = "Contains the EIP allocation ID"
  value       = aws_eip.ec2-eip.id
}

output "public_ip" {
  description = "Contains the public IP address"
  value       = aws_eip.ec2-eip.public_ip
}

output "public_dns" {
  description = "Public DNS associated with the Elastic IP address"
  value       = aws_eip.ec2-eip.public_dns
}
