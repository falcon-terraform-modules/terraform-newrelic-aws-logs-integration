variable "newrelic_license_key" {
  description = "This is your New Relic ingest license key, and it is needed for Kinesis Firehose to successfully send logs to your New Relic account."
  type        = string
}

variable "newrelic_collector_endpoint" {
  description = "This is the New Relic collector endpoint. The URL changes based on your account region (US/EU), and can be found on https://docs.newrelic.com/jp/docs/logs/forward-logs/stream-logs-using-kinesis-data-firehose."
  type        = string
  default     = "https://aws-api.newrelic.com/firehose/v1"
}

variable "log_subscription_filters" {
  description = "Specifies the parameters necessary to configure CloudWatch Logs subscription filter."
  type        = list(map(string))
}

variable "firehose_bucket_expiration_days" {
  description = "Specifies the retention period for error records of Firehose. The value must be `0` or greater. If this parameter is not specified, the retention period will be indefinite."
  type        = number
  default     = null
}