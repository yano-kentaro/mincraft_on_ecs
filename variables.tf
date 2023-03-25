# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "region" {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "minecraft"
  description = "Project name"
}

variable "minecraft_server_image" {
  type        = string
  default     = "itzg/minecraft-server:latest"
  description = "Docker image for the Minecraft server"
}

variable "efs_performance_mode" {
  type        = string
  default     = "generalPurpose"
  description = "EFS performance mode"
}
