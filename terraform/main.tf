provider "aws" {
  region = var.aws_region
}

# VPC and Network Setup
resource "aws_vpc" "cn_project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cn-project-vpc"
  }
}

resource "aws_internet_gateway" "cn_project_igw" {
  vpc_id = aws_vpc.cn_project_vpc.id

  tags = {
    Name = "cn-project-igw"
  }
}

resource "aws_subnet" "cn_project_subnet" {
  vpc_id                  = aws_vpc.cn_project_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "cn-project-subnet"
  }
}

resource "aws_route_table" "cn_project_rt" {
  vpc_id = aws_vpc.cn_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cn_project_igw.id
  }

  tags = {
    Name = "cn-project-rt"
  }
}

resource "aws_route_table_association" "cn_project_rta" {
  subnet_id      = aws_subnet.cn_project_subnet.id
  route_table_id = aws_route_table.cn_project_rt.id
}

# Security Group
resource "aws_security_group" "cn_project_sg" {
  name        = "cn_project_sg"
  description = "Allow all internal traffic and external SSH/HTTP/HTTPS"
  vpc_id      = aws_vpc.cn_project_vpc.id

  # Allow all internal traffic within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow SSH from anywhere (for management)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cn-project-sg"
  }
}

# AMI lookup (Ubuntu 24.04 LTS)
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Mac 1: DNS Server + Client
resource "aws_instance" "mac1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.cn_project_subnet.id
  private_ip             = "10.0.1.10"
  vpc_security_group_ids = [aws_security_group.cn_project_sg.id]
  user_data              = file("${path.module}/../scripts/setup_mac1.sh")

  tags = {
    Name = "Mac1-DNS-Client"
    Role = "DNS"
  }
}

# Mac 2: Edge / Reverse Proxy + Load Balancer
resource "aws_instance" "mac2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.cn_project_subnet.id
  private_ip             = "10.0.1.20"
  vpc_security_group_ids = [aws_security_group.cn_project_sg.id]
  user_data              = file("${path.module}/../scripts/setup_mac2.sh")

  tags = {
    Name = "Mac2-Edge-Proxy"
    Role = "LoadBalancer"
  }
}

# Mac 3: Backend Server A
resource "aws_instance" "mac3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.cn_project_subnet.id
  private_ip             = "10.0.1.30"
  vpc_security_group_ids = [aws_security_group.cn_project_sg.id]
  user_data              = file("${path.module}/../scripts/setup_mac3.sh")

  tags = {
    Name = "Mac3-Backend-A"
    Role = "BackendA"
  }
}

# Mac 4: Backend Server B + Test Client
resource "aws_instance" "mac4" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.cn_project_subnet.id
  private_ip             = "10.0.1.40"
  vpc_security_group_ids = [aws_security_group.cn_project_sg.id]
  user_data              = file("${path.module}/../scripts/setup_mac4.sh")

  tags = {
    Name = "Mac4-Backend-B-Client"
    Role = "BackendB"
  }
}
