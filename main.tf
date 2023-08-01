# Networking for project Prod-VPC

resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

# public subnet 1

resource "aws_subnet" "prod-pub-sub-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {

    Name = "Pro-pub-sub-1"
  }
}

# public subnet 2

resource "aws_subnet" "prod-pub-sub-2" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "prod-pub-sub-2"
  }
}

# Private subnet 1

resource "aws_subnet" "prod-priv-sub-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "prod-priv-sub 1"
  }
}

# Private subnet 2

resource "aws_subnet" "prod-priv-sub-2" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "prod-priv-sub-2a"
  }
}

# Public route tables

resource "aws_route_table" "prod-pub-RT" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-pub-RT"
  }
}

# association public subnet to public route

resource "aws_route_table_association" "prod-pub-sub-1" {
  subnet_id      = aws_subnet.prod-pub-sub-1.id
  route_table_id = aws_route_table.prod-pub-RT.id
}

resource "aws_route_table_association" "prod-pub-sub-2" {
  subnet_id      = aws_subnet.prod-pub-sub-2.id
  route_table_id = aws_route_table.prod-pub-RT.id

}


# Private route table

resource "aws_route_table" "prod-priv-RT" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-priv-RT"
  }
}

# associate private subnet to private route tables

resource "aws_route_table_association" "prod-priv-sub-1" {
  subnet_id      = aws_subnet.prod-priv-sub-1.id
  route_table_id = aws_route_table.prod-priv-RT.id
}

resource "aws_route_table_association" "Prod-priv-sub-2" {
  subnet_id      = aws_subnet.prod-priv-sub-2.id
  route_table_id = aws_route_table.prod-priv-RT.id
}

# internet gateway

resource "aws_internet_gateway" "prod-IGW" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-IGW"
  }
}

# internet gateway association

resource "aws_route_table_association" "Prod-internet-gateway-association" {
  gateway_id     = aws_internet_gateway.prod-IGW.id
  route_table_id = aws_route_table.prod-pub-RT.id
}

# IGW destination

resource "aws_route_table" "IGW-destination" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-IGW.id
  }
  
  tags = {
    name = "IGW-destination"
  }
}


# create Elastic IP Address

resource "aws_eip" "grace-elastic-IP-address" {
  tags = {
    name = "grace-elastic-IP-address"
  }
}


# create NAT Gateway

resource "aws_nat_gateway" "prod-NAT-gateway" {
  allocation_id = aws_eip.grace-elastic-IP-address.id
  subnet_id     = aws_subnet.prod-pub-sub-1.id

  tags = {
    Name = "prod-NAT-gateway"
  }

}

# NAT Associate with Priv route

resource "aws_route" "prod-Nat-Association" {
  route_table_id         = aws_route_table.prod-priv-RT.id
  gateway_id             = aws_nat_gateway.prod-NAT-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}


