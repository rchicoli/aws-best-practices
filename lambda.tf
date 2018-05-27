resource "aws_lambda_function" "rc_webapper" {
  # s3_bucket = "rc-webapper-filestash"
  # s3_bucket = "code-repo"
  # s3_key    = "rc_webapper.zip"
  filename = "rc_webapper.zip"

  function_name = "rc_webapper"

  role    = "${aws_iam_role.rc_webapper.arn}"
  handler = "aws-webapper"
  runtime = "go1.x"
  timeout = "5"

  vpc_config {
    subnet_ids         = ["${aws_subnet.subnet-rc_webapper-1a.id}", "${aws_subnet.subnet-rc_webapper-1b.id}", "${aws_subnet.subnet-rc_webapper-1c.id}"]
    security_group_ids = ["${aws_security_group.sg_rc_webapper_test-default.id}"]
  }

  tags {
    Name = "rc_webapper"
  }
}

resource "aws_lambda_permission" "lambda-s3-rc-webapper" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rc_webapper.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.rc_webapper.arn}"
}

resource "aws_s3_bucket_notification" "bucket_rc_webapper_notification" {
  bucket = "${aws_s3_bucket.rc_webapper.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.rc_webapper.arn}"
    events              = ["s3:ObjectCreated:*"]

    # filter_prefix       = "content-packages/"
    # filter_suffix       = ".csv"
  }
}
