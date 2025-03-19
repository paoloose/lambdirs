variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "base_cidr_block" {
  description = "The /16 CIDR range definition that the VPC will use"
  default     = "10.0.0.0/16"
}

variable "admin_public_key" {
  description = "Public key for the admin user"
  type        = string
}

variable "internal_s3_bucket" {
  // Only if you are storing your state in S3
  description = "S3 bucket to store the OpenTofu state"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix to use for bucket names, as it must be globally unique"
  type        = string
}

// We use a locals block because variables does not support dynamic defaults
locals {
  env = terraform.workspace
}
