resource "aws_s3_bucket" "filestash" {
  bucket = "${var.name}-filestash"
  acl    = "private"

  #   policy = <<POLICY
  # {
  #   "Version": "2008-10-17",
  #   "Statement": [
  #     {
  #       "Sid": "AllowPublicRead",
  #       "Effect": "Allow",
  #       "Principal": {
  #         "AWS": "*"
  #       },
  #       "Action": "s3:GetObject",
  #       "Resource": "arn:aws:s3:::rc-webapper-filestash/*"
  #     }
  #   ]
  # }
  # POLICY

  tags {
    Name = "rc_webapper"
  }
}
