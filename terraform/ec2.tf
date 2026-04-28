data "aws_ami" "os_image" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.jenkins_key_name
  public_key = file("${path.module}/cloudkart-key.pub")
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "jenkins_sg" {
  name        = "cloudkart-jenkins-sg"
  description = "Security group for Jenkins CI/CD server"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudkart-jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.os_image.id
  instance_type   = var.jenkins_instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.jenkins_sg.id]
  user_data       = file("${path.module}/install_tools.sh")

  tags = {
    Name = "CloudKart-Jenkins-Server"
  }

  root_block_device {
    volume_size = var.jenkins_volume_size
    volume_type = "gp3"
  }

  depends_on = [aws_key_pair.deployer]
}