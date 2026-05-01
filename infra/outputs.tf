output "api_endpoint" {
  value = aws_apigatewayv2_api.intake_api.api_endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.intake.name
}

output "lambda_function_name" {
  value = aws_lambda_function.submit_intake.function_name
}