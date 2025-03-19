resource "aws_s3_bucket" "lambdirs" {
  bucket        = var.internal_s3_bucket
  force_destroy = true

  tags = {
    Name = var.internal_s3_bucket
  }
}

resource "aws_s3_bucket_policy" "lambdirs" {
  bucket = aws_s3_bucket.lambdirs.id
  policy = data.aws_iam_policy_document.lambdirs_bucket_policy_doc.json

  depends_on = [aws_s3_bucket.lambdirs]
}

data "aws_iam_policy_document" "lambdirs_bucket_policy_doc" {
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.lambdirs.arn,
      "${aws_s3_bucket.lambdirs.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
