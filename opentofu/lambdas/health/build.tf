resource "terraform_data" "build" {
  provisioner "local-exec" {
    working_dir = local.lambda_root
    command     = "bun run build"
  }

  triggers_replace = local.version
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = local.lambda_entrypoint
  output_path = "${local.lambda_root}/dist/lambda.zip"

  depends_on = [terraform_data.build]
}

resource "terraform_data" "deploy" {
  provisioner "local-exec" {
    command = "aws s3 cp ${data.archive_file.lambda.output_path} s3://${var.internal_bucket}/${local.lambda_s3_key}"
  }

  depends_on       = [data.archive_file.lambda]
  triggers_replace = local.version
}

/* Local and outputs */

locals {
  lambda_root       = "${path.root}/../lambdas/health"
  lambda_entrypoint = "${local.lambda_root}/dist/lambda.mjs"
  lambda_s3_key     = "lambdas/${var.env}/health/health_${local.version}.zip"

  package_json = jsondecode(file("${local.lambda_root}/package.json"))
  version      = local.package_json.version
}

output "build_hash" {
  value = terraform_data.build.triggers_replace
}

output "version" {
  value = local.version
}
