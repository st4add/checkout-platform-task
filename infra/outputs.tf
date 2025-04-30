output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.checkout_lambda.lambda_function_arn
}

output "invoke_url"{
  description = "The invoke Url for the API Gateway"
  value = <<EOF
curl -H "x-api-key:<your api key>" ${module.checkout_rest_api_gateway.invoke_url}
EOF
}