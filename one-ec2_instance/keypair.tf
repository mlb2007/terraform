resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key-pair"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.ec2_key_pair.key_name}.pem"
  content = tls_private_key.ssh.private_key_pem
  file_permission = "0400"

  provisioner "local-exec" {
    command = "rm -f ec2-key-pair.pem"
    when = destroy
  }

}

output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
  sensitive = true
}

