resource "terraform_data" "build" {
  provisioner "local-exec" {
    working_dir = local.lambda_root
    command     = "bun run build"
  }

  triggers_replace = sha1(join("", [for file in local.watch_files : filesha1(file)]))
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = local.lambda_entrypoint
  output_path = "payload.zip"

  depends_on = [terraform_data.build]
}

resource "aws_s3_object" "build" {
  bucket = "paoloose-lambdirs-internal"
  source = data.archive_file.lambda.output_path
  key    = "health/payload.zip"

  depends_on = [data.archive_file.lambda]

  lifecycle {
    replace_triggered_by = [terraform_data.build.triggers_replace]
  }
}

/* Local and outputs */

locals {
  lambda_root       = "${path.root}/../lambdas/health"
  lambda_entrypoint = "${local.lambda_root}/dist/lambda.js"

  watch_files = [
    "${local.lambda_root}/handler.ts",
    "${local.lambda_root}/package.json",
    "${local.lambda_root}/bun.lock",
  ]
}

output "build_hash" {
  value = terraform_data.build.triggers_replace
}
