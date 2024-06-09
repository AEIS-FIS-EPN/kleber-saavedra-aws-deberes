provider "aws" {
  shared_config_files      = ["C:/Users/AlexanderSaavedra/.aws/config"]
  shared_credentials_files = ["C:/Users/AlexanderSaavedra/.aws/credentials"]
}

# es el primer modulo que debe ir en el codigo por buenas practicas
module "vpc" {
  source = "./modules/vpc"
}

# subnet depende de la vpc
# porque la vpc es un conjunto de subnets?
# depends_on: intenta esperar a que otro recurso se haya creado antes de crear el recurso actual
# logica de orden si importa.
# 
# que utilizas de una vpc, en una subnet? R: la vpc_id
module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.company_vpc_id
}

module "security_group" {
  source = "./modules/security_group"
  company_vpc_id = module.vpc.company_vpc_id
}

module "network_interface" {
  source = "./modules/network_interface"
  subnet_id = module.subnet.subnet_id
  security_group_id = module.security_group.security_group_id
}

module "ec2_instances" {
  source = "./modules/ec2_instances"
  company_network_interface_id = module.network_interface.company_network_interface_id
  private_ips = module.network_interface.private_ips
  depends_on = [ module.network_interface ]
}

module "ecr" {
  source = "./modules/ecr"
}

output "public_ip" {
  value = module.ec2_instances.company_public_ip
}

output "private_ip" {
  value = module.ec2_instances.company_private_ip
  description = "value"
}

output "url_ecr_repository_company" {
  value = module.ecr.url_ecr_respository_company
}


# resource "aws_subnet" "public_subnet" {
#   cidr_block = "10.0.1.0/24"
#   vpc_id     = module.vpc.company_vpc_id
#   tags = {
#     Name = "company public subnet"
#   }
# }






# resource "aws_network_interface" "company_network_interface" {
#   subnet_id       = aws_subnet.public_subnet.id
#   private_ips     = ["10.0.1.8"]
#   security_groups = [aws_security_group.web_server_sg.id]
#   tags = {
#     Name = "company network interface"
#   }
# }




