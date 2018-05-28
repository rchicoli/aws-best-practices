resource "aws_lambda_function" "process-requests" {
  # s3_bucket = "rc-webapper-filestash"
  # s3_bucket = "code-repo"
  # s3_key    = "rc_webapper.zip"
  filename = "rc_webapper.zip"

  function_name = "${var.name}"

  role    = "${aws_iam_role.rc-admin.arn}"
  handler = "aws-webapper"
  runtime = "go1.x"
  timeout = "5"

  vpc_config {
    subnet_ids         = ["${aws_subnet.private.*.id}", "${aws_subnet.public.*.id}"]
    security_group_ids = ["${aws_security_group.internal.id}"]
  }

  tags {
    Name        = "${var.name}-${format("%02d", count.index+1)}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_lambda_permission" "allow-s3-access" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.process-requests.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.filestash.arn}"
}

resource "aws_s3_bucket_notification" "trigger-s3-object-created" {
  bucket = "${aws_s3_bucket.filestash.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.process-requests.arn}"
    events              = ["s3:ObjectCreated:*"]

    # filter_prefix       = "content-packages/"
    # filter_suffix       = ".csv"
  }
}
