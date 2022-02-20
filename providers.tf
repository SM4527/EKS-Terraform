provider "aws" {
  region = "${local.region}"
  profile = "${var.AWS_PROFILE}"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
# token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", "${local.cluster_name}"]
    command     = "aws"
  }
  config_path = "/code/kubeconfig_${terraform.workspace}"
# load_config_file       = false
}

provider "kubectl" {
 host                   = module.eks.cluster_endpoint
 token                  = data.aws_eks_cluster_auth.this.token
 cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
 exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", "${local.cluster_name}"]
    command     = "aws"
  }
  config_path = "/code/kubeconfig_${terraform.workspace}"
  load_config_file       = false
}
