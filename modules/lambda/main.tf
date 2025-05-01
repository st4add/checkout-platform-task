######################
#         S3         #
######################
# Configuring for unique S3 naming convention
resource "random_pet" "bucket_name" {
  separator = "-"
  length    = 2
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.function_name}-${lower(random_pet.bucket_name.id)}"

  tags   = var.tags

}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
######################
#       Lambda       #
######################

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.function_name
  description   = var.description
  handler       = var.handler
  source_path   = var.file_path
  runtime       = var.runtime
  publish       = true
  use_existing_cloudwatch_log_group = false
  cloudwatch_logs_retention_in_days = var.log_group_retention

  store_on_s3 = true
  s3_bucket   = aws_s3_bucket.lambda_bucket.id

  tags = var.tags
}

# Allows API Gateway to invoke the lambda function
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_arn}/*/*"
}