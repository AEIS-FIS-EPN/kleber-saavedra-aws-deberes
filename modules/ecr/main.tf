resource "aws_ecr_repository" "ecr_repository_company" {
  name = "test-terraform-repository"
}

output "url_ecr_respository_company" {
  value = aws_ecr_repository.ecr_repository_company.repository_url
}