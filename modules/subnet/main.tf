variable "vpc_id" {
  
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

# de esta manera usamos modulos en vez de codigo directo en el archivo padre
resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = var.vpc_id
  tags = {
    Name = "company public subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = var.vpc_id
  tags = {
    Name = "company private subnet"
  }
}

resource "aws_internet_gateway" "company_public_internet_gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name = "company public internet gateway"
  }
}

resource "aws_route_table" "company_public_subnet_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.company_public_internet_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.company_public_internet_gateway.id
  }

  tags = {
    Name = "company public subnet route table"
  }
}

resource "aws_route_table_association" "company_public_association" {
  route_table_id = aws_route_table.company_public_subnet_route_table.id
  subnet_id      = aws_subnet.public_subnet.id

  # tags = {
  #   Name = "company public subnet route table association"
  # }
}

