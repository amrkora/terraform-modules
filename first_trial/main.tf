resource "aws_security_group" "rds" {
  name = "${var.name}-rds"
  description = "${var.name} RDS serverless access"
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
    description = "All outbound traffic"
  }

  dynamic "ingress" {
    for_each = var.security_groups
    content {
      from_port = 3306
      protocol = "tcp"
      to_port = 3306
      description = ingress.value
      security_groups = [
        ingress.key]
    }
  }

  tags = {
    Name = "${var.name}-rds"
    Product = var.product_tag
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  filter {
    name = "tag:Name"
    values = [
      "rds*"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name = var.name
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    Name = var.name
    Product = var.product_tag
  }
}

resource "aws_rds_cluster" "rds" {
  cluster_identifier = var.name
  database_name = var.name
  master_username = var.database_username
  master_password = var.database_password

  apply_immediately = true
  vpc_security_group_ids = [
    aws_security_group.rds.id]
  skip_final_snapshot = true
  engine_mode = "serverless"
  db_subnet_group_name = aws_db_subnet_group.rds.name

  scaling_configuration {
    auto_pause = true
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
    seconds_until_auto_pause = var.auto_pause
    timeout_action = "ForceApplyCapacityChange"
  }

  tags = {
    Product = var.product_tag
  }
}