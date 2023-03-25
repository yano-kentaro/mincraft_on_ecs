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

# ---------------------------------------------
# Route Tables
# ---------------------------------------------
resource "aws_route_table" "minecraft_route_table" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_igw.id
  }

  tags = {
    Name    = "${var.project}_route_table"
    Project = var.project
    Type    = "public"
  }
}

# ---------------------------------------------
# Route Table Associations
# ---------------------------------------------
resource "aws_route_table_association" "minecraft_route_table_association_1" {
  subnet_id      = aws_subnet.minecraft_subnet_1.id
  route_table_id = aws_route_table.minecraft_route_table.id
}

resource "aws_route_table_association" "minecraft_route_table_association_2" {
  subnet_id      = aws_subnet.minecraft_subnet_2.id
  route_table_id = aws_route_table.minecraft_route_table.id
}
