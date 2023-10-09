# Create a VPC 
resource "aws_vpc" "tf_vpc_new" {
cidr_block = var.vpc_cidr_blocks
tags = {
    "Name" = "${var.env_prefix}-vpc"
}
}
# Create a subnet 
resource "aws_subnet" "tf_public_subnet_1" {
    cidr_block = var.subnet_cidr_blocks 
    vpc_id = aws_vpc.tf_vpc_new.id
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        "Name" = "${var.env_prefix}-public-subnet-1"

    }
}
# create  a IGW 
resource "aws_internet_gateway" "tf_vpc_igw"{
    vpc_id = aws_vpc.tf_vpc_new.id 
    tags = {
        "Name" = "${var.env_prefix}-igw"
    }
}
# create Route table 
resource "aws_route_table" "tf_public_route_table" {
    vpc_id = aws_vpc.tf_vpc_new.id 
    tags = {
        "Name" = "${var.env_prefix}-rtb"
    }
}
# Create a route for Internet access 
resource "aws_route" "tf_public_route" {
    route_table_id = aws_route_table.tf_public_route_table.id
    gateway_id = aws_internet_gateway.tf_vpc_igw.id
    destination_cidr_block = "0.0.0.0/0"
}
# associate a route table with subnet 
resource "aws_route_table_association" "tf_rt_pub_asso"{
    route_table_id = aws_route_table.tf_public_route_table.id
    subnet_id = aws_subnet.tf_public_subnet_1.id
}
# create a security group 

resource "aws_security_group" "tf_sg_new" {
    name = "production-vpc-sg"
    description = "Allow SSH and HTTP from the internet"
    vpc_id = aws_vpc.tf_vpc_new.id
    ingress {
        description = "allow ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.public_ip]
    }
    ingress {
        description = "allow http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.public_ip]
    }
    ingress {
        description = "allow 8080"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.public_ip]
    }

    egress {
description = "allow all ports outbound"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.public_ip]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        "Name" = "${var.env_prefix}"
    }
}