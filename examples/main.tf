module "aws-logs-integration" {
  source               = "falcon-terraform-modules/aws-logs-integration/newrelic"
  newrelic_license_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  log_subscription_filters = [
    {
      log_group_name = "/aws/lambda/hoge"
      name           = "forward_error_logs_to_newrelic"
      filter_pattern = "ERROR"
    },
    {
      log_group_name = "/aws/rds/cluster/hoge/postgresql"
      name           = "forward_slowquery_logs_to_newrelic"
      filter_pattern = "\"LOG:  duration\""
    }
  ]
  firehose_bucket_expiration_days = 7
}