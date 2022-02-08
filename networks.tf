data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.3"
  # insert the required variables here
  name = "vpc-${local.cluster_name}"
  cidr = "${local.vpc_cidr}"
  azs =  data.aws_availability_zones.available.names
  private_subnets= "${local.vpc_private_subnets}" 
  public_subnets= "${local.vpc_public_subnets}" 

  enable_dns_support = true
  enable_dns_hostnames = true

 # NAT Gateway
  enable_nat_gateway = true
  single_nat_gateway = false

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-load-balancers-troubleshooting/
# ingress-nginx controller service - SyncLoadBalancerFailed
    "kubernetes.io/role/elb" = 1
  }
}