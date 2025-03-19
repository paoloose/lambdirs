/* Endpoints */

module "lambda_health" {
  source = "./lambdas/health"

  rest_api_id       = aws_api_gateway_rest_api.lambdirs.id
  root_resource_id  = aws_api_gateway_rest_api.lambdirs.root_resource_id
  env               = local.env
  api_execution_arn = aws_api_gateway_rest_api.lambdirs.execution_arn
  internal_bucket   = var.internal_s3_bucket
}

module "lambda_upload" {
  source = "./lambdas/upload"

  rest_api_id       = aws_api_gateway_rest_api.lambdirs.id
  root_resource_id  = aws_api_gateway_rest_api.lambdirs.root_resource_id
  env               = local.env
  api_execution_arn = aws_api_gateway_rest_api.lambdirs.execution_arn
  internal_bucket   = var.internal_s3_bucket

  api_gateway_authorizer_id = aws_api_gateway_authorizer.lambdirs.id
}
