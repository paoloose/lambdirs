/* Lamdirs outputs */

output "opensearch_proxy_ip" {
  value = aws_instance.opensearch_proxy.public_ip
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.lambdirs.invoke_url
}

output "opensearch_endpoint" {
  value = "https://${aws_opensearch_domain.main.endpoint}"
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.lambdirs.id
}

output "cognito_user_pool_domain" {
  value = "https://${aws_cognito_user_pool_domain.lambidrs.domain}.auth.${var.aws_region}.amazoncognito.com"
}
