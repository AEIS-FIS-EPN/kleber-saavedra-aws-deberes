variable "subnet_id" {
  
}

variable "security_group_id" {
  
}

output "company_network_interface_id" {
  value = aws_network_interface.company_network_interface.id
}

output "private_ips" {
  value = aws_network_interface.company_network_interface.private_ips
}

resource "aws_network_interface" "company_network_interface" {
  subnet_id       = var.subnet_id
  private_ips     = ["10.0.1.8"]
  security_groups = [var.security_group_id]
  tags = {
    Name = "company network interface"
  }
}

