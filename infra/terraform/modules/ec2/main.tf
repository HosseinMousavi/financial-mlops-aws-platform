variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "instance_type" { type = string }
variable "allowed_ingress_cidr" { type = string }
variable "instance_profile" { type = string }

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Dev EC2 access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ops" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker git python3-pip
    systemctl enable docker
    systemctl start docker
  EOF

  tags = { Name = "${var.name_prefix}-ops-host" }
}

output "public_ip" { value = aws_instance.ops.public_ip }
