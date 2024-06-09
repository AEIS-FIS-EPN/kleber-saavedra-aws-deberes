resource "aws_vpc" "company_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "company vpc"
  }
}

output "company_vpc_id" {
  value = aws_vpc.company_vpc.id
}
