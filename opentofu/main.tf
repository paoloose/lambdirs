terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91"
    }
  }

  backend "s3" {
    bucket               = var.internal_s3_bucket
    key                  = "terraform.tfstate"
    region               = var.aws_region
    workspace_key_prefix = "opentofu"
    // Final path will be /opentofu/[workspace]/terraform.tfstate
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_resourcegroups_group" "rg" {
  name = "${local.env}-resource-group"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [{
        Key    = "Environment"
        Values = ["${local.env}"]
      }]
    })
  }

  tags = {
    Environment = local.env
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

output "api_gateway_url" {
  value = aws_api_gateway_stage.lambdirs.invoke_url
}
