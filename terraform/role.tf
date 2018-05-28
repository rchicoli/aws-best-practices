resource "aws_iam_role" "rc_webapper" {
  name = "rc_webapper"

  #   path = "/"

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

resource "aws_iam_policy" "rc_webapper" {
  name        = "rc_webapper"
  path        = "/"
  description = ""

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

resource "aws_iam_policy_attachment" "rc_webapper-policy-attachment" {
  name = "rc_webapper-policy-attachment"

  policy_arn = "${aws_iam_policy.rc_webapper.arn}"
  groups     = []
  users      = []
  roles      = ["rc_webapper"]
}
