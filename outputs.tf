output "minecraft_nlb_dns_name" {
  description = "The DNS name of the Application Load Balancer for the Minecraft server"
  value       = aws_lb.minecraft_nlb.dns_name
}
