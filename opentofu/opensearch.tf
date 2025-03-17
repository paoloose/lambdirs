resource "aws_opensearch_domain" "main" {
  domain_name    = "lambdirs"
  engine_version = "OpenSearch_2.7"

  cluster_config {
    instance_type                 = "t3.small.search"
    instance_count                = 1
    dedicated_master_enabled      = false
    multi_az_with_standby_enabled = false
    warm_enabled                  = false
    zone_awareness_enabled        = false

    cold_storage_options {
      enabled = false
    }
  }

  vpc_options {
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [aws_security_group.opensearch.id]
  }

  domain_endpoint_options {
    custom_endpoint = false
  }

  ebs_options {
    volume_size = 10 // 10GB free tier
    ebs_enabled = true
  }

  tags = {
    Name        = "${local.env}:main"
    Environment = local.env
  }
}

/* Access policies */

data "aws_iam_policy_document" "opensearch_access_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["es:*"]
    resources = [
      aws_opensearch_domain.main.arn,
      "${aws_opensearch_domain.main.arn}/*",
    ]
  }
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.main.domain_name
  access_policies = data.aws_iam_policy_document.opensearch_access_policy_doc.json
}

/* Security group */

resource "aws_security_group" "opensearch" {
  name        = "opensearch_"
  description = "Open search security group"
  vpc_id      = aws_vpc.lambdirs.id

  tags = {
    Name        = "${local.env}:opensearch"
    Environment = local.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "opensearch" {
  security_group_id = aws_security_group.opensearch.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535

  tags = {
    Name        = "${local.env}:opensearch_ingress_all"
    Environment = local.env
  }
}

resource "aws_vpc_security_group_egress_rule" "opensearch" {
  security_group_id = aws_security_group.opensearch.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535

  tags = {
    Name        = "${local.env}:opensearch_egress_all"
    Environment = local.env
  }
}

/* Outputs */

output "opensearch_endpoint" {
  value = aws_opensearch_domain.main.endpoint
}
