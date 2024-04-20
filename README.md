<!-- BEGIN_TF_DOCS -->
# New Relic AWS CloudWatchLogs Integration Terraform module
This Terraform module constructs and configures the necessary resources for integrating AWS CloudWatchLogs into New Relic.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.32.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.46.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_subscription_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_newrelic_license_key"></a> [newrelic\_license\_key](#input\_newrelic\_license\_key) | This is your New Relic ingest license key, and it is needed for Kinesis Firehose to successfully send logs to your New Relic account. | `string` | n/a | yes |
| <a name="input_newrelic_collector_endpoint"></a> [newrelic\_collector\_endpoint](#input\_newrelic\_collector\_endpoint) | This is the New Relic collector endpoint. The URL changes based on your account region (US/EU), and can be found on https://docs.newrelic.com/jp/docs/logs/forward-logs/stream-logs-using-kinesis-data-firehose. | `string` | `"https://aws-api.newrelic.com/firehose/v1"` | no |
| <a name="input_log_subscription_filters"></a> [log\_subscription\_filters](#input\_log\_subscription\_filters) | Specifies the parameters necessary to configure CloudWatch Logs subscription filter. | `list(map(string))` | n/a | yes |
| <a name="input_firehose_bucket_expiration_days"></a> [firehose\_bucket\_expiration\_days](#input\_firehose\_bucket\_expiration\_days) | Specifies the retention period for error records of Firehose. The value must be `0` or greater. If this parameter is not specified, the retention period will be indefinite. | `number` | `null` | no |

## Outputs

No outputs.

## Nested Inputs Reference
### log\_subscription\_filters
- `log_group_name` - Specifies the name of the log group to be monitored. The log group names specified within the list need to be unique; therefore, in this module, it is not possible to set multiple subscription filters for the same log group name.
- `name` - Specifies the name of the subscription filter to be set for the monitored log group. Since the subscription filter names within a log group need to be unique, it is necessary to specify a name that does not duplicate any subscription filter names already configured in the log group. Additionally, only up to two subscription filters are allowed per log group, so be mindful of the number of subscription filters already set for the log group.
- `filter_pattern` - Specifies the filter pattern for the logs to be filtered in the monitored log group. Logs filtered here will be sent to NewRelic. Use an empty string `""` to match all logs. For details on the filter pattern, refer to [Amazon CloudWatch Logs User Guide](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html).

## Usage
### 1. Deploy module with refer to example usage

## Example Usage
```hcl
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
```
<!-- END_TF_DOCS -->