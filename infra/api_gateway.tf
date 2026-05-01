resource "aws_apigatewayv2_api" "intake_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["Content-Type"]
    allow_methods = ["OPTIONS", "POST"]
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "submit_intake" {
  api_id                 = aws_apigatewayv2_api.intake_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.submit_intake.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "submit_intake" {
  api_id    = aws_apigatewayv2_api.intake_api.id
  route_key = "POST /intake"
  target    = "integrations/${aws_apigatewayv2_integration.submit_intake.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.intake_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.submit_intake.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.intake_api.execution_arn}/*/*"
}