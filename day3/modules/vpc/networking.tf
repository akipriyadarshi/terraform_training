resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.tenancy

  tags = {
    Name = "main"
  }
}

data "aws_availability_zones" "available"{
    state = "available"
}

resource "aws_subnet" "public_subnet_new" {
  vpc_id     = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = var.subnet_cidr_public
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-new"
  }
}


resource "aws_subnet" "private_subnet_new" {
  vpc_id     = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = var.subnet_cidr_private
  map_public_ip_on_launch = true

  tags = {
    Name = "private-subnet-new"
  }
}

resource "aws_internet_gateway" "gw-new" {
    vpc_id = aws_vpc.main.id
    tags = {
      "Name" = "demo-ig-new"
    }
  
}

resource "aws_eip" "nat-eip" {
    tags = {
      "Name" = "demo-eip"
    }
  
}

resource "aws_nat_gateway" "nat-gw-new" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = aws_subnet.public_subnet_new.id
    tags = {
      "Name" = "demo-nat-gm-new"
    }
  
}


resource "aws_route_table" "public-rt-new" {
    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw-new.id
     
    } 
    tags = {
      "Name" = "public-route-table_new"
    }
  
}


resource "aws_route_table" "private-rt-new" {
    vpc_id = aws_vpc.main.id
    route   {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat-gw-new.id
     
    } 
    tags = {
      "Name" = "private-route-table_new"
    }
  
}


resource "aws_route_table_association" "public-rta-new" {
    subnet_id = aws_subnet.public_subnet_new.id
    route_table_id = aws_route_table.public-rt-new.id
  
}

resource "aws_route_table_association" "private-rta-new" {
    subnet_id = aws_subnet.private_subnet_new.id
    route_table_id = aws_route_table.private-rt-new.id
  
}

resource "aws_security_group" "public_instance_new" {
    #name = "allow_ssh1"
    vpc_id = aws_vpc.main.id

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
    "Name" = "public-sg-new"
  }
}

resource "aws_security_group" "private_instance_new" {
   # name = "allow_ssh2"
    vpc_id = aws_vpc.main.id

    ingress   {
      cidr_blocks = [aws_vpc.main.cidr_block]
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
    "Name" = "private-sg-new"
  }
}




output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id_public" {
  value = aws_subnet.public_subnet_new.id
}
output "subnet_id_private" {
  value = aws_subnet.private_subnet_new.id
  
}