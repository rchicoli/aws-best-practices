data "aws_availability_zones" "all" {}

# https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Route_Tables.html
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  tags {
    Name = "${var.name}-private"
  }
}

resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name        = "${var.name}-public"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.main.id}"
  count                   = "${length(data.aws_availability_zones.all.names)}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.all.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.name}-private-${format("%02d", count.index+1)}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "private" {
  route_table_id = "${aws_default_route_table.main.id}"
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  count                   = "${length(data.aws_availability_zones.all.names)}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, length(aws_subnet.private.*.id)+count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.all.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.name}-public-${format("%02d", count.index+1)}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = "${aws_route_table.internet.id}"
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

# resource "aws_network_interface" "eni" {
#   subnet_id = "${aws_subnet.public.0.id}"

#   # private_ips       = ["10.8.0.33"]
#   security_groups   = ["${aws_security_group.internal.id}"]
#   source_dest_check = true

#   tags {
#     Name        = "${var.name}-public"
#     Environment = "${terraform.workspace}"
#   }
# }

resource "aws_default_security_group" "main" {
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = []
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group" "internal" {
#   name   = "internal"
#   vpc_id = "${aws_vpc.main.id}"

#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     security_groups = []
#     self            = true
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group_rule" "web_ssh_in" {
#   security_group_id = "${aws_security_group.web.id}"
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"

#   # cidr_blocks              = ["0.0.0.0/0"]
#   source_security_group_id = "${aws_security_group.bastion.id}"
# }

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.main.id}"
  subnet_ids   = ["${aws_subnet.private.*.id}"]
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_default_route_table.main.id}"
}

resource "aws_vpc_endpoint" "kinesis" {
  vpc_id       = "${aws_vpc.main.id}"
  subnet_ids   = ["${aws_subnet.private.*.id}"]
  service_name = "com.amazonaws.${var.region}.kinesis-streams"
}

resource "aws_vpc_endpoint_route_table_association" "kinesis" {
  vpc_endpoint_id = "${aws_vpc_endpoint.kinesis.id}"
  route_table_id  = "${aws_default_route_table.main.id}"
}
