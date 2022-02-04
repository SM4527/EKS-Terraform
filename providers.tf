provider "aws" {
  region = "${local.region}"
  profile = "${var.AWS_PROFILE}"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
# token                  = data.terraform_remote_state.eks.outputs.EKS_cluster_auth_token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", "${local.cluster_name}"]
    command     = "aws"
  }
  config_path = "/code/kubeconfig_${terraform.workspace}"
# load_config_file       = false
}
