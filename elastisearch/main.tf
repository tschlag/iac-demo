data "aws_eks_cluster" "this" {
  name = "travis-admission-controller"
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_security_group" "this" {
  name        = "elasticsearch"
  description = "Managed by Terraform"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.this.cidr_block,
    ]
  }
}

resource "aws_elasticsearch_domain" "datahub" {
  depends_on = [aws_iam_service_linked_role.this]

  domain_name           = "datahub"
  elasticsearch_version = "8.12"

  encrypt_at_rest {
    enabled = true
  }

  advanced_security_options {
    enabled = true
  }

  vpc_options {
    subnet_ids         = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }
}