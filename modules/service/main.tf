locals {
  container_port = 8080
}

resource "aws_cloudwatch_log_group" "app" {
  count = var.enabled ? 1 : 0

  # AWS-managed encryption avoids a paid KMS key in this small environment.

  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_iam_role" "execution" {
  count = var.enabled ? 1 : 0

  name = "${var.name}-ecs-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "execution_logs" {
  count = var.enabled ? 1 : 0

  name = "cloudwatch-logs-only"
  role = aws_iam_role.execution[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "WriteApplicationLogs"
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.app[0].arn}:*"
    }]
  })
}

resource "aws_iam_role" "task" {
  count = var.enabled ? 1 : 0

  name = "${var.name}-ecs-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_security_group" "alb" {
  count = var.enabled ? 1 : 0

  name        = "${var.name}-alb"
  description = "Allow public HTTPS to the application load balancer"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count = var.enabled ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Public HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_security_group" "task" {
  count = var.enabled ? 1 : 0

  name        = "${var.name}-task"
  description = "Allow application traffic only from the ALB"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-task-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "task_from_alb" {
  count = var.enabled ? 1 : 0

  # Ingress is limited to the ALB security group, not the public internet.

  security_group_id            = aws_security_group.task[0].id
  description                  = "Application traffic from ALB"
  referenced_security_group_id = aws_security_group.alb[0].id
  from_port                    = local.container_port
  to_port                      = local.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_tasks" {
  count = var.enabled ? 1 : 0

  security_group_id            = aws_security_group.alb[0].id
  description                  = "ALB traffic to application tasks"
  referenced_security_group_id = aws_security_group.task[0].id
  from_port                    = local.container_port
  to_port                      = local.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "task_https" {
  count = var.enabled ? 1 : 0

  security_group_id = aws_security_group.task[0].id
  description       = "HTTPS egress for image pulls and AWS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_lb" "this" {
  count = var.enabled ? 1 : 0

  # ALB logging requires a log archive bucket and is documented as a production extension.
  # AWS WAF creates recurring cost and is an optional internet-edge hardening control.

  name                       = substr("${var.name}-alb", 0, 32)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb[0].id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = var.deletion_protection
  tags                       = var.tags
}

resource "aws_lb_target_group" "app" {
  count = var.enabled ? 1 : 0

  name        = substr("${var.name}-tg", 0, 32)
  port        = local.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
  tags = var.tags
}

resource "aws_lb_listener" "https" {
  count = var.enabled ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[0].arn
  }
}

resource "aws_ecs_cluster" "this" {
  count = var.enabled ? 1 : 0

  name = "${var.name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource "aws_ecs_task_definition" "app" {
  count = var.enabled ? 1 : 0

  family                   = "${var.name}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution[0].arn
  task_role_arn            = aws_iam_role.task[0].arn

  volume {
    name = "temporary-files"
  }
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name                   = "app"
    image                  = var.container_image
    essential              = true
    readonlyRootFilesystem = true
    user                   = "101"
    portMappings           = [{ containerPort = local.container_port, protocol = "tcp" }]
    mountPoints = [{
      sourceVolume  = "temporary-files"
      containerPath = "/tmp"
      readOnly      = false
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app[0].name
        awslogs-region        = data.aws_region.current.region
        awslogs-stream-prefix = "app"
      }
    }
    healthCheck = {
      command     = ["CMD-SHELL", "wget -q -O - http://127.0.0.1:8080/ || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])
  tags = var.tags
}

data "aws_region" "current" {}

resource "aws_ecs_service" "app" {
  count = var.enabled ? 1 : 0

  name                               = "${var.name}-service"
  cluster                            = aws_ecs_cluster.this[0].id
  task_definition                    = aws_ecs_task_definition.app[0].arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_execute_command             = false
  wait_for_steady_state              = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.task[0].id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app[0].arn
    container_name   = "app"
    container_port   = local.container_port
  }

  depends_on = [aws_lb_listener.https]
  tags       = var.tags
}

resource "aws_appautoscaling_target" "ecs" {
  count = var.enabled ? 1 : 0

  max_capacity       = 6
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.this[0].name}/${aws_ecs_service.app[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enabled ? 1 : 0

  name               = "${var.name}-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
