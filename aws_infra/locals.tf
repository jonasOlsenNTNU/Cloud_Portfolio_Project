locals {
  //ECR Variables
  bucket_name   = "tf-state-bucket-project-portfolio"
  table_name    = "tf-state-lock-table"
  ecr_repo_name = "portfolio-ecr-repo"

  //ECS Variables
  portfolio_ecs_cluster_name = "portfolio-cluster"
  //AZs: eun1-az1 | eun1-az2 | eun1-az3
  availability_zones = ["eu-north-1a", "eu-north-1b"]

  webapp_task_family           = "webapp-task"
  container_port               = 3000
  webapp_task_name             = "webapp-task"
  esc_task_execution_role_name = "webapp-task-execution-role"

  application_load_balancer_name = "load-balancer"
  target_group_name              = "portfolio-tg"
  portfolio_ecs_service_name     = "portfolio-service"
}