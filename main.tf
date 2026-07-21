resource "aws_sns_topic" "vss" {
  name              = var.name
  kms_master_key_id = var.kms

  policy = templatefile("${var.policy_path}/${var.name}.json", {
    account = "${var.accountID}"
  })
  delivery_policy = templatefile("${var.delivery_policy_path}/${var.name}.json", {
    account = "${var.accountID}"
  })

  tags = {
    Name = var.name
  }
}

resource "aws_sns_topic_subscription" "vss" {
  for_each = var.subscriptions

  topic_arn = aws_sns_topic.vss.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  endpoint_auto_confirms = lookup(each.value, "auto_confirm", true)
}