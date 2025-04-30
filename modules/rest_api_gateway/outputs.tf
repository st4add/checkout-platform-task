output "execution_arn" {
  description = "The ARN of the api gateway"
  value       = aws_api_gateway_rest_api.checkout_rest_api.execution_arn
}

output "gateway_name" {
  description = "Name of the API Gateway rest API"
  value       = aws_api_gateway_rest_api.checkout_rest_api.name
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.test_stage.stage_name
}

output "invoke_url" {
  description = "REST API invoke URL"
  value       = aws_api_gateway_stage.test_stage.invoke_url
}