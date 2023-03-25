# ---------------------------------------------
# Minecraft Network Load Balancer
# ---------------------------------------------
resource "aws_lb" "minecraft_nlb" {
  name               = "minecraft-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets = [
    aws_subnet.minecraft_subnet_1.id,
    aws_subnet.minecraft_subnet_2.id
  ]

  tags = {
    Name    = "${var.project}_nlb"
    Project = var.project
  }
}

resource "aws_lb_target_group" "minecraft_target_group" {
  name        = "minecraft-tg"
  port        = 25565
  protocol    = "TCP"
  vpc_id      = aws_vpc.minecraft_vpc.id
  target_type = "ip"

  tags = {
    Name    = "${var.project}_tg"
    Project = var.project
  }
}

resource "aws_lb_listener" "minecraft_listener" {
  load_balancer_arn = aws_lb.minecraft_nlb.arn
  port              = 25565
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minecraft_target_group.arn
  }

  tags = {
    Name    = "${var.project}_listener"
    Project = var.project
  }
}
