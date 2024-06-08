provider "aws" {
  shared_config_files      = ["C:/Users/AlexanderSaavedra/.aws/config"]
  shared_credentials_files = ["C:/Users/AlexanderSaavedra/.aws/credentials"]
}

resource "aws_vpc" "company_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "company vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.company_vpc.id
  tags = {
    Name = "company public subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.company_vpc.id
  tags = {
    Name = "company private subnet"
  }
}

resource "aws_internet_gateway" "company_public_internet_gateway" {
  vpc_id = aws_vpc.company_vpc.id
  tags = {
    Name = "company public internet gateway"
  }
}

resource "aws_route_table" "company_public_subnet_route_table" {
  vpc_id = aws_vpc.company_vpc.id

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

resource "aws_security_group" "web_server_sg" {
  vpc_id = aws_vpc.company_vpc.id

  ingress {
    description = "Allow HTTP traffic from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "company security group"
  }
}

// bloque de datos se usa cuando se quiere agregar informacion especifica de un recurso
// vamos a intentar definir una AMI
// plantilla ubuntu: ubuntu focal 20.04
// hay que hacer un estudio de lo que necesitamos en una imagen e incluso esto afectaria el costo
// https://releases.ubuntu.com/focal/
data "aws_ami" "ubuntu_ami" {
  most_recent = "true"
  filter {
    name = "name" // aqui va el nombre del sistema operativo
    # values = ["ubuntu/images/pvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  # esta seria la forma de implemementar la busqueda para Azure porque Azure usa vp, al parecer
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  //https://documentation.ubuntu.com/aws/en/latest/aws-how-to/instances/find-ubuntu-images/
  // esta metadata te sirve sobre todo cuando quieres hacer migraciones para poder tener las mismas caracteristicas en otro servidor
  // a diferencia de cuando se hace directamente desde la interfaz de usuario porque se pierde mucha informacion sobre las instancias, muchas caracteristicas
  owners = ["099720109477"]

  tags = {
    Name = "ubuntu focal 20.04"
  }
}

// Instance EC2
resource "aws_instance" "ubuntu-company-instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.company_network_interface.id
    device_index         = 0
  }
  user_data = <<-EOF
              #!bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              EOF
  tags = {
    Name = "Ubuntu company instance"
  }
}

resource "aws_network_interface" "company_network_interface" {
  subnet_id       = aws_subnet.public_subnet.id
  private_ips     = ["10.0.1.8"]
  security_groups = [aws_security_group.web_server_sg.id]
  tags = {
    Name = "company network interface"
  }
}

resource "aws_eip" "company_ip_elastica" {
  associate_with_private_ip = tolist(aws_network_interface.company_network_interface.private_ips)[0]
  network_interface         = aws_network_interface.company_network_interface.id
  instance = aws_instance.ubuntu-company-instance.id
  tags = {
    Name = "company elastic ip"
  }
}

# output "company_public_ip" {
#   value = aws_eip.company_ip_elastica.public_ip
#   vpc = true
#   network_interface = aws_network_interface.company_network_interface.id
# }

# output "public_company_ip" {
#   value = aws_eip.company_ip_elastica.public_ip
# }
