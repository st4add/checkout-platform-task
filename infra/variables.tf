variable "backend_bucket" {
  description = "Name of the S3 bucket to store Terraform state"
  default     = "backenbucket18"
  type        = string
}

variable "bucket_key" {
  description = "Path within the S3 bucket where the state file is stored (e.g. \"prod/terraform.tfstate\")"
  default     = "prod"
  type        = string
}

variable "aws_region" {
  description = "AWS region for both the backend bucket and deployed resources"
  default     = "eu-west-2"
  type        = string
}

variable "lock_table" {
  description = "Name of the DynamoDB table to use for Terraform state locking"
  default     = "state-lock"
  type        = string
}