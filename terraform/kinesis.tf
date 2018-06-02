resource "aws_kinesis_stream" "requests" {
  name             = "${var.name}-requests"
  shard_count      = 4
  retention_period = 24

  # https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Name        = "${var.name}"
    Environment = "${terraform.workspace}"
  }
}
