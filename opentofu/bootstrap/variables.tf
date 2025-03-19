// Only if you are storing your state in S3
variable "internal_s3_bucket" {
  description = "S3 bucket to store the OpenTofu state"
  type        = string
}
