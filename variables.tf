variable "accountID" {
  description = "The AWS Account ID where the SNS topic will be created."
  type        = string
}

variable "name" {
  description = "The name of the SNS topic. Also used to find the JSON file names."
  type        = string
}

variable "kms" {
  description = "The ARN for the KMS encryption key."
  type        = string
  default     = null
}

variable "policy_path" {
  description = "The directory path where the access policy JSON files are stored."
  type        = string
}

variable "delivery_policy_path" {
  description = "The directory path where the delivery policy JSON files are stored."
  type        = string
  default     = "./"
}

variable "subscriptions" {
  description = "A map of subscriptions to create for this topic."
  type = map(object({
    protocol     = string
    endpoint     = string
    auto_confirm = optional(bool, true)
  }))
  default = {}
}