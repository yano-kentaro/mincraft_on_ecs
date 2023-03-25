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

