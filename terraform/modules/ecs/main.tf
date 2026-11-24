resource "aws_ecs_cluster" "devsecops_dev_ecs_cluster" {
  name = "${var.name_prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled" #費用が発生するためいったん無効化
  }

  tags = {
    Name = "${var.name_prefix}-ecs-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "devsecops_dev_ecs_task_definition" {
  family                   = "${var.name_prefix}-ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.devsecops_dev_role_ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "${var.name_prefix}-container"
      image     = var.image_uri
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

      runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
      }

  tags = {
    Name = "${var.name_prefix}-ecs-task-definition"
  }
}
resource "aws_security_group" "devsecops_dev_sg_ecs" {
  name        = "${var.name_prefix}-sg-ecs"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_cidr_blocks
    content {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ecs-sg"
  }
}

resource "aws_ecs_service" "devsecops_dev_ecs_service" {
  name            = "${var.name_prefix}-ecs-service"
  cluster         = aws_ecs_cluster.devsecops_dev_ecs_cluster.id
  task_definition = aws_ecs_task_definition.devsecops_dev_ecs_task_definition.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_id]
    security_groups  = [aws_security_group.devsecops_dev_sg_ecs.id]
    assign_public_ip = true
  }

  tags = {
    Name = "${var.name_prefix}-ecs-service"
  }
}