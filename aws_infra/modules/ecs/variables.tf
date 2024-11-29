variable "portfolio_ecs_cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "availability_zones" {
  description = "eu-north-1 AZ"
  type        = list(string)
}

variable "application_load_balancer_name" {
  description = "Load Balancer name"
  type        = string
}

variable "target_group_name" {
  description = "Target group name"
}

variable "container_port" {
  description = "Exposed container port"
  type        = number
}

variable "portfolio_ecs_service_name" {
  description = "ECS service name"
  type        = string
}

variable "webapp_task_family" {
  description = "Webapp task family"
  type        = string
}

variable "webapp_task_name" {
  description = "Webapp task name"
  type        = string
}

variable "ecr_repo_url" {
  description = "ECR Repository URL (from ecr/outputs)"
  type        = string
}

variable "esc_task_execution_role_name" {
  description = "ECS task execution role name"
  type        = string
}