variable "env" {
  type = string
}

/* API Gateway */

resource "aws_api_gateway_rest_api" "lambdirs" {
  name        = "${var.env}:lambdirs"
  description = "Lambdirs ${var.env} API Gateway"
}

/* Deployment and stage */

resource "aws_api_gateway_deployment" "lambdirs" {
  description = "Lambdirs ${var.env} deployment"
  rest_api_id = aws_api_gateway_rest_api.lambdirs.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.lambdirs.body))
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
  description   = "Lambdirs ${var.env} stage"
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
    Name        = "${var.env}:lambdirs"
    Environment = var.env
  }
}

/* Logs */

resource "aws_cloudwatch_log_group" "lambdirs_gw" {
  name              = "/aws/apigateway/lambdirs"
  retention_in_days = 7

  tags = {
    Name        = "${var.env}:lambdirs"
    Environment = var.env
  }
}

/* Endpoints */

module "lambda_health" {
  source = "./health"

  rest_api_id       = aws_api_gateway_rest_api.lambdirs.id
  root_resource_id  = aws_api_gateway_rest_api.lambdirs.root_resource_id
  env               = var.env
  api_execution_arn = aws_api_gateway_rest_api.lambdirs.execution_arn
}

/* Outputs */

output "api_gateway_url" {
  value = aws_api_gateway_stage.lambdirs.invoke_url
}
