resource "aws_ecs_cluster" "portfolio_ecs_cluster" {
  name = var.portfolio_ecs_cluster_name
}
resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = var.availability_zones[0]
}
resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = var.availability_zones[1]
}

resource "aws_ecs_task_definition" "webapp_task" {
  family                   = var.webapp_task_family
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.webapp_task_name}",
      "image": "${var.ecr_repo_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.esc_task_execution_role.arn
}

resource "aws_iam_role" "esc_task_execution_role" {
  name               = var.esc_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "esc_task_execution_role_policy" {
  role       = aws_iam_role.esc_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
  "${aws_default_subnet.default_subnet_b.id}"]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {}

resource "aws_vpc_security_group_egress_rule" "load_balancer_security_group_egress" {
  security_group_id = aws_security_group.load_balancer_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "load_balancer_security_group_ingress" {
  security_group_id = aws_security_group.load_balancer_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}



resource "aws_lb_target_group" "target_group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_service" "portfolio_ecs_service" {
  name          = var.portfolio_ecs_service_name
  cluster       = aws_ecs_cluster.portfolio_ecs_cluster.id
  task_definition = aws_ecs_task_definition.webapp_task.arn
  launch_type   = "FARGATE"
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.webapp_task.family
    container_port   = var.container_port
  }

  network_configuration {
    subnets = [
      "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

resource "aws_security_group" "service_security_group" {
}

resource "aws_vpc_security_group_egress_rule" "service_security_group_egress" {
  security_group_id = aws_security_group.service_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "service_security_group_ingress" {
  security_group_id = aws_security_group.service_security_group.id

  referenced_security_group_id = aws_security_group.load_balancer_security_group.id
  ip_protocol                  = "-1"
}