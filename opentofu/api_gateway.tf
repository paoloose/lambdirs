/* API Gateway */

resource "aws_api_gateway_rest_api" "lambdirs" {
  name        = "${local.env}:lambdirs"
  description = "Lambdirs ${local.env} API Gateway"
}

/* Deployment and stage */

resource "aws_api_gateway_deployment" "lambdirs" {
  description = "Lambdirs ${local.env} deployment"
  rest_api_id = aws_api_gateway_rest_api.lambdirs.id

  triggers = {
    redeployment = md5(jsonencode([
      module.lambda_health.version,
      module.lambda_upload.version,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api.lambdirs,
    aws_api_gateway_account.apigw_account,
  ]
}

resource "aws_api_gateway_stage" "lambdirs" {
  description   = "Lambdirs ${local.env} stage"
  rest_api_id   = aws_api_gateway_rest_api.lambdirs.id
  deployment_id = aws_api_gateway_deployment.lambdirs.id
  stage_name    = "v1"

  depends_on = [aws_api_gateway_deployment.lambdirs]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambdirs_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  tags = {
    Name        = "${local.env}:lambdirs"
    Environment = local.env
  }
}

/* Logs */

resource "aws_cloudwatch_log_group" "lambdirs_gw" {
  name              = "/aws/apigateway/lambdirs"
  retention_in_days = 7

  tags = {
    Name        = "${local.env}:lambdirs"
    Environment = local.env
  }
}

/* APi Gateway role and policies */

resource "aws_api_gateway_account" "apigw_account" {
  cloudwatch_role_arn = aws_iam_role.lambdirs.arn
}

resource "aws_iam_role" "lambdirs" {
  name = "APIGatewayCloudWatchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambdirs_policy" {
  name        = "APIGatewayLoggingPolicy"
  description = "Allows API Gateway to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambdirs" {
  policy_arn = aws_iam_policy.lambdirs_policy.arn
  role       = aws_iam_role.lambdirs.name
}
