data "aws_availability_zones" "all" {}
data "aws_availability_zones" "all" {}

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

  # TODO: create a custom table for public access
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.rt-private-subnet-tag}"
  }
}

# resource "aws_route_table" "custom" {
#   vpc_id = "${aws_vpc.main.id}"

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "${aws_internet_gateway.main.id}"
#   }

#   tags {}
# }

resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.all.names)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    "Name"      = "${var.name}_${format("%02d", count.index+1)}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "rtb-decd26b4-rtbassoc-dee404b3" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  route_table_id = "${aws_route_table.main.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

# resource "aws_network_interface" "eni-a31d2b89" {
#   subnet_id         = "subnet-429afb3f"
#   private_ips       = ["10.8.0.33"]
#   security_groups   = ["sg-d4aeaab9"]
#   source_dest_check = true
# }

resource "aws_security_group" "internal" {
  name        = "sg_rc_webapper-default"
  description = "rc_webapper"
  vpc_id      = "${aws_vpc.main.id}"

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
  service_name = "${format("com.amazonaws.%s.s3", var.region)}"
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.main.id}"
}
