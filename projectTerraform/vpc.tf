resource "aws_vpc" "tenacity_vpc" {
  cidr_block                                = "10.0.0.0/16"
  instance_tenancy                          = "default"

  enable_dns_support                        = true
  enable_dns_hostnames                      = true


  tags = {
    Name = "tenacity_vpc"
  }
}

#Public Subnets

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.tenacity_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.tenacity_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

#Private Subnets
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.tenacity_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.tenacity_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod-priv-sub2"
  }
}

#Route tables
resource "aws_route_table" "prod-pub-route-table" {
  vpc_id = aws_vpc.tenacity_vpc.id
  tags = {
    Name = "prod-pub-route-table"
  }
}

resource "aws_route_table" "prod-priv-route-table" {
  vpc_id = aws_vpc.tenacity_vpc.id
  tags = {
    Name = "prod-priv-route-table"
  }
}

#Public subnet association
resource "aws_route_table_association" "pub-association1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

resource "aws_route_table_association" "pub-association2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

#Private subnet association
resource "aws_route_table_association" "priv-association1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}

resource "aws_route_table_association" "priv-association2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}

#aws_internet_gateway
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.tenacity_vpc.id

  tags = {
    Name = "prod-igw"
  }
}

#aws_internet_gateway route
resource "aws_route" "Public_route" {
    route_table_id     = aws_route_table.prod-pub-route-table.id
   gateway_id          = aws_internet_gateway.prod-igw.id
    destination_cidr_block    = "0.0.0.0/0"
}

#aws_nat_gateway

#eip
resource "aws_eip" "prod-nat-eip" {
    domain  = "vpc"

    tags = {
        Name = "prod-nat-eip"
    }

}
resource "aws_nat_gateway" "prod-nat-gateway" {
  allocation_id = aws_eip.prod-nat-eip.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "prod-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prod-igw]
}

#aws_nat_gateway route
resource "aws_route" "Private_route" {
    route_table_id     = aws_route_table.prod-priv-route-table.id
    nat_gateway_id     = aws_nat_gateway.prod-nat-gateway.id
    destination_cidr_block    = "0.0.0.0/0"
    
}