variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description for the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda function handler (module_path.function_name)"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Lambda function (e.g., python3.9)"
  type        = string
}

variable "file_path" {
  description = "Path to the directory containing the Lambda code"
  type        = string
}


variable "tags" {
  description = "Map of tags to apply to all Lambda-related resources"
  type        = map(string)
  default     = {}
}

variable "api_gateway_arn" {
  description = "Path to the directory containing the Lambda code"
  type        = string
}

variable "log_group_retention" {
  description = "log retention"
  type        = number
}