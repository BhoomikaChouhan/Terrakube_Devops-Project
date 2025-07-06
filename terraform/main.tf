provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default VPC's subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "bhoomika-eks"
  cluster_version = "1.28"
  vpc_id          = data.aws_vpc.default.id
  subnets         = data.aws_subnet_ids.default.ids

  node_groups = {
    default_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }

  manage_aws_auth = true
  enable_irsa     = true
}

