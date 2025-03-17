terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket               = var.backend_s3_bucket
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
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "lambdas" {
  source = "./lambdas"
}
