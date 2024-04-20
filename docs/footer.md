## Nested Inputs Reference
### log_subscription_filters
- `log_group_name` - Specifies the name of the log group to be monitored. The log group names specified within the list need to be unique; therefore, in this module, it is not possible to set multiple subscription filters for the same log group name.
- `name` - Specifies the name of the subscription filter to be set for the monitored log group. Since the subscription filter names within a log group need to be unique, it is necessary to specify a name that does not duplicate any subscription filter names already configured in the log group. Additionally, only up to two subscription filters are allowed per log group, so be mindful of the number of subscription filters already set for the log group.
- `filter_pattern` - Specifies the filter pattern for the logs to be filtered in the monitored log group. Logs filtered here will be sent to NewRelic. Use an empty string `""` to match all logs. For details on the filter pattern, refer to [Amazon CloudWatch Logs User Guide](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html).

## Usage
### 1. Deploy module with refer to example usage