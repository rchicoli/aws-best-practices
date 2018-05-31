resource "aws_s3_bucket" "filestash" {
  bucket = "${var.name}-filestash"
  acl    = "private"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.name}-logs"
  acl    = "private"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_s3_bucket_policy" "allow-cloudwatch-logs-to-export-to-s3" {
  bucket = "${aws_s3_bucket.filestash.id}"

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
      "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.eu-west-1.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}/*",
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
