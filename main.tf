locals {
  region_short_name = {
    us-east-1      = "use1"
    us-east-2      = "use2"
    us-west-1      = "usw1"
    us-west-2      = "usw2"
    ap-south-1     = "aps1"
    ap-northeast-1 = "apne1"
    ap-northeast-2 = "apne2"
    ap-northeast-3 = "apne3"
    ap-southeast-1 = "apse1"
    ap-southeast-2 = "apse2"
    ca-central-1   = "cac1"
    eu-central-1   = "euc1"
    eu-west-1      = "euw1"
    eu-west-2      = "euw2"
    eu-west-3      = "euw3"
    eu-north-1     = "eun1"
    sa-east-1      = "sae1"
  }
}

locals {
  cwlogs_role_name     = "LogsRole-FirehosePutRecords-NewRelic"
  cwlogs_policy_name   = "LogsPolicy-FirehosePutRecords-NewRelic"
  firehose_role_name   = "KinesisFirehoseServiceRole-PUT-LogStreams-NewRelic"
  firehose_policy_name = "KinesisFirehoseServicePolicy-PUT-LogStreams-NewRelic"
  firehose_stream_name = "NewRelic-LogStreams"
  firehose_bucket_name = "firehose-backup-newrelic-logstreams"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role" {
  for_each = toset([
    "firehose",
    "logs.${data.aws_region.current.name}"
  ])
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "${each.value}.amazonaws.com"
      ]
    }
  }
}

resource "aws_s3_bucket" "firehose" {
  bucket        = "${local.firehose_bucket_name}-${data.aws_caller_identity.current.account_id}-${local.region_short_name[data.aws_region.current.name]}"
  force_destroy = true
  tags = {
    Name = "${local.firehose_bucket_name}-${data.aws_caller_identity.current.account_id}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_s3_bucket_versioning" "firehose" {
  bucket = aws_s3_bucket.firehose.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "firehose" {
  bucket = aws_s3_bucket.firehose.bucket
  dynamic "rule" {
    for_each = var.firehose_bucket_expiration_days != null ? [1] : []
    content {
      id     = "expiration"
      status = "Enabled"
      expiration {
        days = var.firehose_bucket_expiration_days
      }
      noncurrent_version_expiration {
        noncurrent_days = 1
      }
    }
  }
  dynamic "rule" {
    for_each = [1]
    content {
      id     = "expiration_delete_markers"
      status = "Enabled"
      expiration {
        expired_object_delete_marker = true
      }
    }
  }
  dynamic "rule" {
    for_each = [1]
    content {
      id     = "abort_incomplete_multipart"
      status = "Enabled"
      abort_incomplete_multipart_upload {
        days_after_initiation = 7
      }
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = "${local.firehose_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role["firehose"].json
  tags = {
    Name = "${local.firehose_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

data "aws_iam_policy_document" "firehose" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.firehose.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.firehose.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "firehose" {
  name   = "${local.firehose_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  policy = data.aws_iam_policy_document.firehose.json
  tags = {
    Name = "${local.firehose_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose.arn
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = local.firehose_stream_name
  destination = "http_endpoint"
  http_endpoint_configuration {
    name               = "New Relic"
    url                = var.newrelic_collector_endpoint
    access_key         = var.newrelic_license_key
    retry_duration     = 60
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = aws_iam_role.firehose.arn
    s3_backup_mode     = "FailedDataOnly"
    s3_configuration {
      role_arn           = aws_iam_role.firehose.arn
      bucket_arn         = aws_s3_bucket.firehose.arn
      buffering_size     = 5
      buffering_interval = 300
      compression_format = "GZIP"
    }
    request_configuration {
      content_encoding = "GZIP"
    }
  }
  tags = {
    Name = local.firehose_stream_name
  }
}

resource "aws_iam_role" "cwlogs" {
  name               = "${local.cwlogs_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role["logs.${data.aws_region.current.name}"].json
  tags = {
    Name = "${local.cwlogs_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

data "aws_iam_policy_document" "cwlogs" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    effect    = "Allow"
    resources = [aws_kinesis_firehose_delivery_stream.main.arn]
  }
}

resource "aws_iam_policy" "cwlogs" {
  name   = "${local.cwlogs_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  policy = data.aws_iam_policy_document.cwlogs.json
  tags = {
    Name = "${local.cwlogs_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  role       = aws_iam_role.cwlogs.name
  policy_arn = aws_iam_policy.cwlogs.arn
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each        = { for i in var.log_subscription_filters : i.log_group_name => i }
  name            = each.value.name
  log_group_name  = each.value.log_group_name
  filter_pattern  = each.value.filter_pattern
  role_arn        = aws_iam_role.cwlogs.arn
  destination_arn = aws_kinesis_firehose_delivery_stream.main.arn
}