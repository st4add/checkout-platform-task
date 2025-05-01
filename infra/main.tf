######################
#  Declaring Locals  #
######################

locals {
  project     = "checkout-task"
  environment = "test"
  default_tags = {
    Project   = local.project
    Owner     = "David Stead"
    ManagedBy = "Terraform"
  }

}


######################
#       Lambda       #
######################
module "checkout_lambda" {
  source              = "../modules/lambda"
  function_name       = "${local.project}-lambda"
  description         = "Lambda function that returns the time and a random fact about AWS"
  handler             = "checkout_lambda.lambda_handler"
  runtime             = "python3.13"
  api_gateway_arn     = module.checkout_rest_api_gateway.execution_arn
  file_path           = "${path.module}/../src/my_lambda/checkout_lambda.py"
  log_group_retention = 7
  tags = merge(
    local.default_tags, {
      Language = "Python"
    }
  )
}

######################
#     API Gateway    #
######################
module "checkout_rest_api_gateway" {
  source              = "../modules/rest_api_gateway"
  stage_name          = local.environment
  gateway_name        = "${local.project}_api_gateway"
  lambda_uri          = module.checkout_lambda.lambda_function_invoke_arn
  log_group_retention = 7
  tags = merge(
    local.default_tags, {
      Gateway = "Rest"
    }
  )
}

######################
# CloudWatch Alarms  #
######################

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${local.project}-api-5xx"
  alarm_description   = "Alarm when API Gateway returns any 5XX errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 1 # any 5xx in the period
  dimensions = {
    ApiName = module.checkout_rest_api_gateway.gateway_name
    Stage   = module.checkout_rest_api_gateway.stage_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-lambda-errors"
  alarm_description   = "Alarm when the Lambda function returns any errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300 # evaluate every 1 minute
  statistic           = "Sum"
  threshold           = 1 # any error in the period triggers it
  dimensions = {
    FunctionName = module.checkout_lambda.lambda_function_name
  }
}