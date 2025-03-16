// Debian proxy to connect to opensearch
resource "aws_instance" "opensearch_proxy" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.debian12_ami.id
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main.id

  key_name = aws_key_pair.opensearch_proxy_admin.key_name

  vpc_security_group_ids = [
    aws_security_group.opensearch_proxy.id
  ]

  volume_tags = {
    Name        = "${local.env}:opensearch_proxy"
    Environment = local.env
  }

  tags = {
    Name        = "${local.env}:opensearch_proxy"
    Environment = local.env
  }
}

resource "aws_key_pair" "opensearch_proxy_admin" {
  key_name   = "${local.env}_opensearch_proxy_admin"
  public_key = var.admin_public_key
}

resource "aws_security_group" "opensearch_proxy" {
  name        = "opensearch_proxy"
  description = "Open search proxy security group"
  vpc_id      = aws_vpc.lambdirs.id

  tags = {
    Name        = "${local.env}:opensearch_proxy"
    Environment = local.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "opensearch_proxy" {
  security_group_id = aws_security_group.opensearch_proxy.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22

  tags = {
    Name        = "${local.env}:opensearch_proxy_ssh"
    Environment = local.env
  }
}

resource "aws_vpc_security_group_egress_rule" "opensearch_proxy" {
  security_group_id = aws_security_group.opensearch_proxy.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535

  tags = {
    Name        = "${local.env}:opensearch_proxy_all"
    Environment = local.env
  }
}

data "aws_ami" "debian12_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
    // See https://aws.amazon.com/marketplace/pp/prodview-g5rooj5oqzrw4
  }

  owners = ["136693071363"]
  // See https://wiki.debian.org/Cloud/AmazonEC2Image/Bookworm
}

output "opensearch_proxy_ip" {
  value = aws_instance.opensearch_proxy.public_ip
}
