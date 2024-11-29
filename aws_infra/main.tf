terraform {

  //Important: Comment out terraform backend declaration below the first time this template is initialized and applied.
  //Otherwise an error is thrown since the s3 bucket does not exist yet.
  /*
  backend "s3" {
    bucket         = "tf-state-bucket-project-portfolio"
    key            = "tf-infra/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "tf-state-lock-table"
    encrypt        = true
  }
*/
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = "~> 1.3"
}

//Module for initializing Terraform Version Control. Stored in S3 Bucket on the AWS Cloud
module "tf-state" {
  source      = "./modules/tf-state"
  bucket_name = local.bucket_name
  table_name  = local.table_name
}

//Module for initializing an ECR for storing container images.
module "ecr-repo" {
  source        = "./modules/ecr"
  ecr_repo_name = local.ecr_repo_name
}

//Module for initializing an ECS cluster
module "ecsCluster" {
  source = "./modules/ecs"

  portfolio_ecs_cluster_name = local.portfolio_ecs_cluster_name
  availability_zones         = local.availability_zones

  webapp_task_family           = local.webapp_task_family
  ecr_repo_url                 = module.ecr-repo.repository_url
  webapp_task_name             = local.webapp_task_name
  container_port               = local.container_port
  esc_task_execution_role_name = local.esc_task_execution_role_name

  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group_name
  portfolio_ecs_service_name     = local.portfolio_ecs_service_name
}