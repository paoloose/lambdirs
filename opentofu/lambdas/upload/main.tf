/* Inputs */

variable "rest_api_id" {
  type        = string
  description = "The ID of the API Gateway REST API"
}

variable "root_resource_id" {
  type        = string
  description = "The ID of the API Gateway root resource"
}

variable "api_execution_arn" {
  type        = string
  description = "The ARN of the API Gateway execution role"
}

variable "env" {
  type = string
}

/* Lambda */

// Docs https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "upload" {
  function_name = "LambdirsUpload"
  description   = "Upload object endpoint for Lambdirs ${var.env}"

  s3_bucket = "paoloose-lambdirs-internal"
  s3_key    = local.lambda_s3_key

  runtime = "nodejs22.x"
  handler = "lambda.handler"
  timeout = 5

  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.upload.arn
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = var.rest_api_id
  parent_id   = var.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "upload" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.upload.invoke_arn
}

/* Logs */

resource "aws_cloudwatch_log_group" "upload" {
  name              = "/aws/lambda/${aws_lambda_function.upload.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "upload" {
  name           = aws_lambda_function.upload.function_name
  log_group_name = aws_cloudwatch_log_group.upload.name

  depends_on = [aws_lambda_function.upload]
}

/* Lambda role */

resource "aws_iam_role" "upload" {
  name = "LambdirsUpload"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "upload" {
  role       = aws_iam_role.upload.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "permissions" {
  // This allows to generate s3 presign urls for uplaoding objects
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
        ],
        Resource = [
          "arn:aws:s3:::paoloose-lambdirs-internal/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "permissions" {
  role       = aws_iam_role.upload.name
  policy_arn = aws_iam_policy.permissions.arn
}

/* API Gateway permission */

// This gives the API Gateway permission to invoke the Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_execution_arn}/*/*/*"
}

/* Outputs */

output "lambda_arn" {
  value = aws_lambda_function.upload.arn
}
