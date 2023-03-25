# ---------------------------------------------
# CloudWatch
# ---------------------------------------------
resource "aws_cloudwatch_log_group" "minecraft_logs" {
  name = "minecraft_logs"

  tags = {
    Name    = "${var.project}_logs"
    Project = var.project
  }
}
