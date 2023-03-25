# ---------------------------------------------
# ECS Cluster
# ---------------------------------------------
resource "aws_ecs_cluster" "minecraft_cluster" {
  name = "minecraft_cluster"

  tags = {
    Name    = "${var.project}_cluster"
    Project = var.project
  }
}

# ---------------------------------------------
# ECS　Service
# ---------------------------------------------
resource "aws_ecs_service" "minecraft_service" {
  name            = "minecraft_service"
  cluster         = aws_ecs_cluster.minecraft_cluster.id
  task_definition = aws_ecs_task_definition.minecraft_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.minecraft_subnet_1.id,
      aws_subnet.minecraft_subnet_2.id
    ]
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

  tags = {
    Name    = "${var.project}_service"
    Project = var.project
  }
}

# ---------------------------------------------
# ECS Task definition
# ---------------------------------------------
resource "aws_ecs_task_definition" "minecraft_task" {
  family                   = "minecraft_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "16384"
  memory                   = "32768"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "minecraft_server"
    image     = var.minecraft_server_image
    cpu       = 16384
    memory    = 32768
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

  tags = {
    Name    = "${var.project}_task"
    Project = var.project
  }
}
