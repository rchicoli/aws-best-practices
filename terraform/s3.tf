resource "aws_s3_bucket" "filestash" {
  bucket = "${var.name}-filestash"
  acl    = "private"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_s3_bucket_policy" "allow-log-export-to-s3" {
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
      "Resource": "arn:aws:s3:::${var.name}-filestash"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.eu-west-1.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.name}-filestash/*",
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
