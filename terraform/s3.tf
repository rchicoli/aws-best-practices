resource "aws_s3_bucket" "filestash" {
  bucket        = "${var.name}-filestash"
  acl           = "private"
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.log.id}"
    target_prefix = "log/"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_s3_bucket" "log" {
  bucket        = "${var.name}-log"
  acl           = "log-delivery-write"
  force_destroy = true

  tags {
    Name = "${var.name}"
  }
}

resource "aws_s3_bucket_policy" "allow-cloudwatch-logs-to-export-to-s3" {
  bucket = "${aws_s3_bucket.log.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.eu-west-1.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.log.id}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.eu-west-1.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.log.id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}
