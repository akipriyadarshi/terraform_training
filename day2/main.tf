provider "aws" {
  region  = "us-east-2"
}

resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr

    tags = {
      "Name" = "vpc_demo-1"
    }
  
}

data "aws_availability_zones" "available"{
    state = "available"
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.0.0/17"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.128.0/17"
  map_public_ip_on_launch = true

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      "Name" = "demo-ig"
    }
  
}

resource "aws_eip" "nat-eip" {
    tags = {
      "Name" = "demo-eip"
    }
  
}

resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = aws_subnet.public_subnet.id
    tags = {
      "Name" = "demo-nat-gm"
    }
  
}

resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.my-vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
     
    } 
    tags = {
      "Name" = "public-route-table"
    }
  
}



resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.my-vpc.id
    route   {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat-gw.id
     
    } 
    tags = {
      "Name" = "private-route-table"
    }
  
}


resource "aws_route_table_association" "public-rta" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public-rt.id
  
}

resource "aws_route_table_association" "private-rta" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private-rt.id
  
}

resource "aws_security_group" "public_instance" {
    name = "allow_ssh1"
    vpc_id = aws_vpc.my-vpc.id

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      protocol = "tcp"
      to_port = 22
    } 

    egress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      protocol = -1
      to_port = 0
    } 
  tags = {
    "Name" = "public-sg"
  }
}

resource "aws_security_group" "private_instance" {
    name = "allow_ssh2"
    vpc_id = aws_vpc.my-vpc.id

    ingress   {
      cidr_blocks = [aws_vpc.my-vpc.cidr_block]
      from_port = 22
      protocol = "tcp"
      to_port = 22
    } 

    egress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      protocol = -1
      to_port = 0
    } 
  tags = {
    "Name" = "private-sg"
  }
}

resource "aws_instance" "public_instance" {
  ami                  = "ami-077e31c4939f6a2f3"
  instance_type        = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
    security_groups = [aws_security_group.public_instance.id]
  tags = {
    Name = "public-ec2"
  }
}


resource "aws_instance" "private_instance" {
  ami                  = "ami-077e31c4939f6a2f3"
  instance_type        = "t2.micro"
  subnet_id = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_instance.id]
  tags = {
    Name = "private-ec2"
  }
}
