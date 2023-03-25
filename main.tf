# ---------------------------------------------
# Terraform configuration for AWS
# ---------------------------------------------
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  profile = "default"
  region  = var.region
}

# Security Group
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_sg"
  description = "Allow inbound traffic for Minecraft server"
  vpc_id      = aws_vpc.minecraft_vpc.id

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS
resource "aws_ecs_cluster" "minecraft_cluster" {
  name = "minecraft_cluster"
}

resource "aws_ecs_task_definition" "minecraft_task" {
  family                   = "minecraft_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "minecraft_server"
    image     = var.minecraft_server_image
    cpu       = 2048
    memory    = 4096
    essential = true
    portMappings = [
      {
        containerPort = 25565
        hostPort      = 25565
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.minecraft_logs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "minecraft"
      }
    }
    environment = [
      {
        name  = "EULA"
        value = "TRUE"
      }
    ]
  }])
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "minecraft_logs" {
  name = "minecraft_logs"
}

resource "aws_lb_target_group" "minecraft_target_group" {
  name        = "minecraft-tg"
  port        = 25565
  protocol    = "TCP"
  vpc_id      = aws_vpc.minecraft_vpc.id
  target_type = "ip"
}

resource "aws_lb" "minecraft_nlb" {
  name               = "minecraft-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.minecraft_subnet_1.id, aws_subnet.minecraft_subnet_2.id]
}

resource "aws_lb_listener" "minecraft_listener" {
  load_balancer_arn = aws_lb.minecraft_nlb.arn
  port              = 25565
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minecraft_target_group.arn
  }
}

resource "aws_ecs_service" "minecraft_service" {
  name            = "minecraft_service"
  cluster         = aws_ecs_cluster.minecraft_cluster.id
  task_definition = aws_ecs_task_definition.minecraft_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.minecraft_subnet_1.id, aws_subnet.minecraft_subnet_2.id]
    security_groups  = [aws_security_group.minecraft_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.minecraft_target_group.arn
    container_name   = "minecraft_server"
    container_port   = 25565
  }

  depends_on = [
    aws_lb_listener.minecraft_listener
  ]
}

