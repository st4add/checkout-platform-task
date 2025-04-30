variable "lambda_uri" {
  description = "Lambda Uri"
  type        = string
}

variable "log_group_retention" {
  description = "log retention"
  type        = number
}

variable "gateway_name" {
  description = "gateway name"
  type        = string
}

variable "stage_name" {
  description = "stage name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all API Gateway resources"
  type        = map(string)
  default     = {}
}