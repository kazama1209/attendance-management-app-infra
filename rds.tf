resource "aws_db_subnet_group" "main" {
  name        = "${var.rsrc_prefix}-dbsg"
  description = "${var.rsrc_prefix}-dbsg"
  subnet_ids  = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  tags = {
    Name = "${var.rsrc_prefix}-dbsg"
  }
}

resource "aws_db_instance" "mysql" {
  identifier          = "${var.rsrc_prefix}-mysql"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  name                = var.database_name
  username            = var.database_username
  password            = var.database_password
  port                = 3306
  multi_az            = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}
