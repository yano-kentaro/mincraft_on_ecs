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
# ECS Task definition
# ---------------------------------------------
resource "aws_ecs_task_definition" "minecraft_task" {
  family                   = "minecraft_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "8192"
  memory                   = "16384"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "minecraft_server"
    image     = var.minecraft_server_image
    cpu       = 8192
    memory    = 16384
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
