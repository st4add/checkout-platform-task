output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.checkout_lambda.lambda_function_arn
}