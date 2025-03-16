resource "aws_vpc" "lambdirs" {
  cidr_block           = var.base_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name        = "${local.env}:lambdirs"
    Environment = local.env
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.lambdirs.id
  cidr_block = cidrsubnet(aws_vpc.lambdirs.cidr_block, 4, 0)
  # See https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html

  tags = {
    Name        = "${local.env}:main"
    Environment = local.env
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.lambdirs.id

  tags = {
    Name        = "${local.env}:main"
    Environment = local.env
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.lambdirs.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
