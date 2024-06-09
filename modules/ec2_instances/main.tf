# resource "aws_vpc" "company_vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "company vpc"
#   }
# }

variable "company_network_interface_id" {
  
}

variable "private_ips" {
  
}

output "name" {
  value = aws_instance.ubuntu-company-instance.id
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
    network_interface_id = var.company_network_interface_id
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

resource "aws_eip" "company_ip_elastica" {
  associate_with_private_ip = tolist(var.private_ips)[0]
  network_interface         = var.company_network_interface_id
  instance = aws_instance.ubuntu-company-instance.id
  tags = {
    Name = "company elastic ip"
  }
}

output "company_public_ip" {
  value = aws_eip.company_ip_elastica.public_ip
}

output "company_private_ip" {
  value = aws_eip.company_ip_elastica.private_ip
}