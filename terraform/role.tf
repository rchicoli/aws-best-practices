resource "aws_iam_role" "rc-admin" {
  name = "rc-admin"

  # path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "rc-admin" {
  name = "rc-admin"

  # path = "/"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "s3:*",
        "apigateway:*",
        "logs:*",
        "ec2:*",
        "lambda:*",
        "kinesis:*"
      ],
      "Resource": "*"
    }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "rc-admin" {
  name       = "iam-admin"
  policy_arn = "${aws_iam_policy.rc-admin.arn}"
  groups     = []
  users      = []
  roles      = ["rc-admin"]
}
