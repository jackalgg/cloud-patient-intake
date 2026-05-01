data "archive_file" "submit_intake_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/submit_intake.py"
  output_path = "${path.module}/submit_intake.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-lambda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.intake.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_lambda_function" "submit_intake" {
  function_name = "${var.project_name}-submit-intake"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "submit_intake.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.submit_intake_zip.output_path
  source_code_hash = data.archive_file.submit_intake_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.intake.name
    }
  }
}