/* Endpoints */

module "lambda_health" {
  source = "./health"

  rest_api_id       = aws_api_gateway_rest_api.lambdirs.id
  root_resource_id  = aws_api_gateway_rest_api.lambdirs.root_resource_id
  env               = var.env
  api_execution_arn = aws_api_gateway_rest_api.lambdirs.execution_arn
}
