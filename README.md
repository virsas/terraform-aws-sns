# Terraform AWS SNS Module

A Terraform module for managing an [Amazon SNS](https://docs.aws.amazon.com/sns/latest/dg/welcome.html) topic together with its subscriptions. The topic's access policy and delivery policy are rendered from JSON templates kept in your own repository, and optional server side encryption is provided by a KMS key.

## Features

- **Topic Management**: Creates a single SNS topic named after the `name` variable and tags it with `Name = <name>`.
- **Templated Access Policy**: Renders the topic access policy from `<policy_path>/<name>.json`, injecting the AWS account ID as the `account` template variable.
- **Templated Delivery Policy**: Renders the topic delivery policy from `<delivery_policy_path>/<name>.json` using the same `account` template variable, so HTTP/S retry behaviour is version controlled alongside the module call.
- **KMS Encryption**: Optionally encrypts messages at rest with a customer managed KMS key.
- **Subscriptions**: Creates any number of subscriptions from a single map, each with its own protocol, endpoint and endpoint auto confirmation setting.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Create a plain topic with no subscriptions.

The module always renders both an access policy and a delivery policy from a file named after the topic, so both of the following files must exist:
- `./json/sns/policy/vss-alerts.json` - the topic access policy
- `./json/sns/delivery/vss-alerts.json` - the topic delivery policy

```hcl
module "sns" {
  source = "git::https://github.com/virsas/terraform-aws-sns.git?ref=v1.1"

  accountID = "123456789012"
  name      = "vss-alerts"

  policy_path          = "./json/sns/policy"
  delivery_policy_path = "./json/sns/delivery"
}
```

### Advanced Example (KMS Encryption & Subscriptions)

Create an encrypted topic and fan it out to an email address, an SQS queue and a Lambda function:

```hcl
module "sns_encrypted" {
  source = "git::https://github.com/virsas/terraform-aws-sns.git?ref=v1.1"

  accountID = "123456789012"
  name      = "vss-alerts"
  kms       = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  policy_path          = "./json/sns/policy"
  delivery_policy_path = "./json/sns/delivery"

  subscriptions = {
    ops_email = {
      protocol = "email"
      endpoint = "ops@example.com"
    }
    worker_queue = {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:eu-west-1:123456789012:vss-alerts"
    }
    alert_handler = {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:eu-west-1:123456789012:function:vss-alert-handler"
    }
  }
}
```

### HTTPS Webhook Example

Subscribe an external HTTPS webhook and disable endpoint auto confirmation so that SNS waits for the endpoint to confirm the subscription itself:

```hcl
module "sns_webhook" {
  source = "git::https://github.com/virsas/terraform-aws-sns.git?ref=v1.1"

  accountID = "123456789012"
  name      = "vss-webhooks"

  policy_path          = "./json/sns/policy"
  delivery_policy_path = "./json/sns/delivery"

  subscriptions = {
    incident_tool = {
      protocol     = "https"
      endpoint     = "https://hooks.example.com/sns/incidents"
      auto_confirm = false
    }
  }
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accountID"></a> [accountID](#input\_accountID) | The AWS account ID where the SNS topic will be created, injected into both policy templates as the `account` variable. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the SNS topic, also used to resolve the policy and delivery policy JSON file names. | `string` | n/a | yes |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | Directory path where the access policy JSON files are stored. The module reads `<policy_path>/<name>.json`. | `string` | n/a | yes |
| <a name="input_delivery_policy_path"></a> [delivery\_policy\_path](#input\_delivery\_policy\_path) | Directory path where the delivery policy JSON files are stored. The module reads `<delivery_policy_path>/<name>.json`. | `string` | `"./"` | no |
| <a name="input_kms"></a> [kms](#input\_kms) | ARN of the KMS key used to encrypt messages at rest. Defaults to `null`, which leaves encryption disabled. | `string` | `null` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | Map of subscriptions to create for this topic, keyed by an arbitrary name. `protocol` is one of `http`, `https`, `email`, `email-json`, `sms`, `sqs`, `application`, `lambda` or `firehose`, `endpoint` is the matching destination, and `auto_confirm` marks the endpoint as auto confirming the subscription. | <pre>map(object({<br>    protocol     = string<br>    endpoint     = string<br>    auto_confirm = optional(bool, true)<br>  }))</pre> | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the SNS topic. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
