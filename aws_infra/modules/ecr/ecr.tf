resource "aws_ecr_repository" "portfolio_ecr_repo" {
  name = var.ecr_repo_name
}