resource "aws_db_instance" "rcwebapper" {
  identifier              = "rcwebapper"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.6.39"
  instance_class          = "db.t2.micro"
  name                    = "rcwebapper"
  username                = "test1234"
  password                = "test1234"
  port                    = 3306
  publicly_accessible     = false
  availability_zone       = "${data.aws_availability_zones.all.names.0}"
  security_group_names    = []
  vpc_security_group_ids  = ["${aws_default_security_group.main.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.rds.id}"
  parameter_group_name    = "default.mysql5.6"
  multi_az                = false
  backup_retention_period = 0

  #   final_snapshot_identifier = "rcwebapper-final"
  skip_final_snapshot = true

  tags {
    Name        = "${var.name}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_db_subnet_group" "rds" {
  subnet_ids = ["${aws_subnet.private.*.id}"]
}
