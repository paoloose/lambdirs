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

variable "internal_bucket" {
  type = string
}

variable "env" {
  type = string
}

/* Lambda */

// Docs https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "health" {
  function_name = "LambdirsHealth"
  description   = "Health check for Lambdirs ${var.env}"

  s3_bucket = var.internal_bucket
  s3_key    = local.lambda_s3_key

  runtime = "nodejs22.x"
  handler = "lambda.handler"
  timeout = 5

  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.health.arn

  depends_on = [terraform_data.deploy]
}

resource "aws_api_gateway_resource" "health" {
  rest_api_id = var.rest_api_id
  parent_id   = var.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.health.invoke_arn
}

/* Logs */

resource "aws_cloudwatch_log_group" "health" {
  name              = "/aws/lambda/${aws_lambda_function.health.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "health" {
  name           = aws_lambda_function.health.function_name
  log_group_name = aws_cloudwatch_log_group.health.name

  depends_on = [aws_lambda_function.health]
}

/* Permissions */

resource "aws_iam_role" "health" {
  name               = "LambdirsHealth"
  assume_role_policy = data.aws_iam_policy_document.health.json
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_execution_arn}/*/*/*"
}

// The health handler does not need any fancy permissions
data "aws_iam_policy_document" "health" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "health" {
  role       = aws_iam_role.health.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

/* Outputs */

output "lambda_arn" {
  value = aws_lambda_function.health.arn
}
