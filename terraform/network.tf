provider "aws" {
  region                  = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

resource "aws_vpc" "rc_webapper" {
  cidr_block           = "10.9.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    "Name" = "rc_webapper"
  }
}

resource "aws_internet_gateway" "rc_webapper" {
  vpc_id = "${aws_vpc.rc_webapper.id}"

  tags {
    "Name" = "rc_webapper"
  }
}

# resource "aws_default_route_table" "rt-private-subnet" {
#   default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

#   tags {
#     Name = "${var.rt-private-subnet-tag}"
#   }
# }

resource "aws_route_table" "rc_webapper" {
  vpc_id = "${aws_vpc.rc_webapper.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rc_webapper.id}"
  }

  tags {}
}

resource "aws_subnet" "subnet-rc_webapper-1a" {
  vpc_id                  = "${aws_vpc.rc_webapper.id}"
  cidr_block              = "10.9.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags {
    "Name" = "rc_webapper"
  }
}

resource "aws_subnet" "subnet-rc_webapper-1b" {
  vpc_id                  = "${aws_vpc.rc_webapper.id}"
  cidr_block              = "10.9.1.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags {
    "Name" = "rc_webapper"
  }
}

resource "aws_subnet" "subnet-rc_webapper-1c" {
  vpc_id                  = "${aws_vpc.rc_webapper.id}"
  cidr_block              = "10.9.2.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = false

  tags {
    "Name" = "rc_webapper"
  }
}

# resource "aws_eip" "rc_webapper" {
#   instance = "rc_webapper"
#   vpc      = true
# }

resource "aws_route_table_association" "rtb-decd26b4-rtbassoc-dee404b3" {
  route_table_id = "${aws_route_table.rc_webapper.id}"
  subnet_id      = "${aws_subnet.subnet-rc_webapper-1a.id}"
}

resource "aws_route_table_association" "rtb-decd26b4-rtbassoc-dfe404b2" {
  route_table_id = "${aws_route_table.rc_webapper.id}"
  subnet_id      = "${aws_subnet.subnet-rc_webapper-1b.id}"
}

resource "aws_route_table_association" "rtb-decd26b4-rtbassoc-56e7073b" {
  route_table_id = "${aws_route_table.rc_webapper.id}"
  subnet_id      = "${aws_subnet.subnet-rc_webapper-1c.id}"
}

# resource "aws_network_interface" "eni-a31d2b89" {
#   subnet_id         = "subnet-429afb3f"
#   private_ips       = ["10.8.0.33"]
#   security_groups   = ["sg-d4aeaab9"]
#   source_dest_check = true
# }

resource "aws_security_group" "sg_rc_webapper_test-default" {
  name        = "sg_rc_webapper-default"
  description = "rc_webapper"
  vpc_id      = "${aws_vpc.rc_webapper.id}"

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

# resource "aws_security_group" "vpc-a3136dc8-rds-launch-wizard-1" {
#     name        = "rds-launch-wizard-1"
#     description = "Created from the RDS Management Console: 2018/05/26 07:39:20"
#     vpc_id      = "vpc-a3136dc8"

#     ingress {
#         from_port       = 3306
#         to_port         = 3306
#         protocol        = "tcp"
#         cidr_blocks     = ["46.5.0.96/32"]
#     }

#     egress {
#         from_port       = 0
#         to_port         = 0
#         protocol        = "-1"
#         cidr_blocks     = ["0.0.0.0/0"]
#     }

# }

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.rc_webapper.id}"
  service_name = "com.amazonaws.eu-west-1.s3"
}

# resource "aws_vpc_endpoint_route_table_association" "endpoint-s3-rta" {
#   vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
#   route_table_id  = "${aws_default_route_table.rc_webapper.id}"
# }
resource "aws_vpc_endpoint_route_table_association" "endpoint-s3-rta" {
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.rc_webapper.id}"
}
