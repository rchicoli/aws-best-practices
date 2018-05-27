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
  availability_zone       = "eu-central-1c"
  security_group_names    = []
  vpc_security_group_ids  = ["${aws_security_group.sg_rc_webapper_test-default.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.rds-subnet-group-rcwebapper.id}"
  parameter_group_name    = "default.mysql5.6"
  multi_az                = false
  backup_retention_period = 0

  # backup_window             = "00:45-01:15"
  # maintenance_window        = "tue:03:24-tue:03:54"
  # final_snapshot_identifier = "rcwebapper-final"
}

resource "aws_db_subnet_group" "rds-subnet-group-rcwebapper" {
  name        = "rds-subnet-group-rcwebapper"
  description = "Subnet group for rds rc_webapper"
  subnet_ids  = ["${aws_subnet.subnet-rc_webapper-1a.id}", "${aws_subnet.subnet-rc_webapper-1b.id}", "${aws_subnet.subnet-rc_webapper-1c.id}"]
}
