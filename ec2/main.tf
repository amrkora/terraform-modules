provider "aws" {
  profile = "default"
  region = "us-east-2"
}

variable "service_name" {
  default = "nyoo_services"
}

data "aws_vpc" "default" {
  default = true
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "ec2_allow_access" {
  name = "ec2_allow_access"
  description = "Allow traffic"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = var.service_name
  }
}
resource "aws_security_group_rule" "allow_ssh" {
  type = "ingress"
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_allow_access.id
}
resource "aws_security_group_rule" "http_80" {
  type = "ingress"
  description = "HTTP"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_allow_access.id
}
resource "aws_security_group_rule" "http_8080" {
  type = "ingress"
  description = "HTTP"
  from_port = 8080
  to_port = 8080
  protocol = "TCP"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_allow_access.id
}
resource "aws_security_group_rule" "all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_allow_access.id
}

resource "aws_key_pair" "nyoo_ec2_deployer" {
  key_name = "deployer-key"
  public_key = file("./ssh/ecy-kp.pub")
  tags = {
    Name = var.service_name
  }
}

data "template_file" "bootstrap_file" {
  template = file("${path.cwd}/bootstrap_file.sh")
}


resource "aws_ebs_volume" "nyoo_ebs_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size = 1
  type = "gp2"
  tags = {
    Name = var.service_name
  }
}

resource "aws_ebs_snapshot" "nyoo_snapshot" {
  volume_id = aws_ebs_volume.nyoo_ebs_volume.id
  tags = {
    Name = var.service_name
  }
}

resource "aws_instance" "nyoo_services" {
  key_name = aws_key_pair.nyoo_ec2_deployer.key_name
  ami = "ami-0f7919c33c90f5b58"
  instance_type = "t2.micro"
  availability_zone = data.aws_availability_zones.available.names[0]
  user_data = data.template_file.bootstrap_file.template
  security_groups = [aws_security_group.ec2_allow_access.name]
  tags = {
    Name = var.service_name
  }
}
//  provisioner "file" {
//    source = "${path.cwd}/nyoo-services-0.1.jar"
//    destination = "/tmp/nyoo-services-0.1.jar"
//  }
resource "aws_volume_attachment" "nyoo_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.nyoo_ebs_volume.id
  instance_id = aws_instance.nyoo_services.id
}