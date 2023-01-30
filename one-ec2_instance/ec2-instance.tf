locals {
  user_data = templatefile("templates/user_data.tftpl", {
      ec2_name = var.ami_name
  })
}

resource "aws_instance" "ec2-instance" {
  ami = var.ami_id
  
  instance_type = var.ec2-instance-type
  
  key_name = aws_key_pair.ec2_key_pair.key_name
  
  security_groups = [aws_security_group.ec2-ssh.id]
  
  subnet_id = aws_subnet.ec2_public_1.id

  user_data = "${base64encode(local.user_data)}"
   
  tags = {
      Name = var.ami_name
  }
}



# eip for our instance
resource "aws_vpc" "ec2-eip-attach" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "ec2-eip-attach"
  }
}

resource "aws_eip" "ec2-eip" {
  instance = "${aws_instance.ec2-instance.id}"
  vpc      = true
}
