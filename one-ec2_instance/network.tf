# Production VPC
resource "aws_vpc" "ec2-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Public subnets
resource "aws_subnet" "ec2_public_1" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.ec2-vpc.id
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "ec2-public-1"
  }
}

# Route tables for the subnets
resource "aws_route_table" "ec2_public" {
  vpc_id = aws_vpc.ec2-vpc.id
}

resource "aws_route_table_association" "ec2_public_1" {
  route_table_id = aws_route_table.ec2_public.id
  subnet_id      = aws_subnet.ec2_public_1.id
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2-vpc.id
}

resource "aws_route" "ec2_internet_gateway" {
  route_table_id         = aws_route_table.ec2_public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
