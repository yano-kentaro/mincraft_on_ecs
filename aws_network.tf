# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "minecraft_vpc" {
  cidr_block                       = "10.1.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name    = "${var.project}_vpc"
    Project = var.project
  }
}

# ---------------------------------------------
# Subnets
# ---------------------------------------------
resource "aws_subnet" "minecraft_subnet_1" {
  cidr_block        = "10.1.0.0/24"
  vpc_id            = aws_vpc.minecraft_vpc.id
  availability_zone = "${var.region}a"
  tags = {
    Name    = "${var.project}_subnet_1"
    Project = var.project
    Type    = "public"
  }
}

resource "aws_subnet" "minecraft_subnet_2" {
  cidr_block        = "10.1.2.0/24"
  vpc_id            = aws_vpc.minecraft_vpc.id
  availability_zone = "${var.region}c"
  tags = {
    Name    = "${var.project}_subnet_2"
    Project = var.project
    Type    = "public"
  }
}
