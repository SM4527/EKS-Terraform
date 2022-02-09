locals {
  env = "${terraform.workspace}"

  region_map = {
    default = "us-east-1"
  }
  region = "${lookup(local.region_map, local.env)}"

  cluster_name_map = {
    default = "Default-EKS-Cluster"
  }
  cluster_name = "${lookup(local.cluster_name_map, local.env)}"

  vpc_cidr_map = {
    default = "10.0.0.0/16"
  }
  vpc_cidr = "${lookup(local.vpc_cidr_map, local.env)}"

# https://cidr.xyz/
  vpc_private_subnets_map = {
    default = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  }
  vpc_private_subnets= "${lookup(local.vpc_private_subnets_map, local.env)}"

   vpc_public_subnets_map = {
    default = ["10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
  }
  vpc_public_subnets= "${lookup(local.vpc_public_subnets_map, local.env)}"

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "${var.AWS_PROFILE}"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "${var.AWS_PROFILE}"
      context = {
        cluster = module.eks.cluster_id
        user    = "${var.AWS_PROFILE}"
      }
    }]
    users = [{
      name = "${var.AWS_PROFILE}"
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1alpha1"
          args        = ["--region","${local.region}","eks", "get-token", "--cluster-name", "${local.cluster_name}"]
          command     = "aws"
          env = [{
            "name" = "AWS_PROFILE"
            "value" = "${var.AWS_PROFILE}"
          }]
        }
      }
    }]
  })

}