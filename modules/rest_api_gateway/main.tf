resource "aws_api_gateway_rest_api" "checkout_rest_api" {
  name        = "checkout-rest_api"
  description = "API Gateway for checkout Lambda function"
}

resource "aws_api_gateway_method" "root_get" {
  rest_api_id      = aws_api_gateway_rest_api.checkout_rest_api.id
  resource_id      = aws_api_gateway_rest_api.checkout_rest_api.root_resource_id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}


resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.checkout_rest_api.id
  resource_id             = aws_api_gateway_rest_api.checkout_rest_api.root_resource_id
  http_method             = aws_api_gateway_method.root_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_uri

}


resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.checkout_rest_api.id
  triggers = {
    redeploy = sha1(jsonencode({
      methods      = aws_api_gateway_method.root_get.id
      integrations = aws_api_gateway_integration.lambda_integration.id
    }))
  }
}

resource "aws_api_gateway_stage" "test_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.checkout_rest_api.id
  stage_name    = var.stage_name
  access_log_settings  {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }
  depends_on = [aws_api_gateway_account.checkout_api_account]
}

# Create an API Gateway API key
resource "aws_api_gateway_api_key" "api_key" {
  name        = "checkout_key"
  description = "API key for my checkout_rest API"
  enabled     = true
}

# Create a Usage Plan
resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "MyUsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.checkout_rest_api.id
    stage  = aws_api_gateway_stage.test_stage.stage_name
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  quota_settings {
    limit  = 10000
    period = "MONTH"
  }
}

# Associate the API key with the Usage Plan
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

# Require API Key for the method
resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.checkout_rest_api.id
  stage_name  = aws_api_gateway_stage.test_stage.stage_name

  method_path = "*/*"  # This is the correct wildcard to override all methods and resources

  settings {
    metrics_enabled = false
    logging_level   = "ERROR"
    data_trace_enabled = false
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name = "/aws/gateway/${var.gateway_name}/${var.stage_name}"
  retention_in_days = var.log_group_retention

  tags = var.tags
}

resource "aws_api_gateway_account" "checkout_api_account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}