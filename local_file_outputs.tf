resource "local_file" "aws_auth_cm" {
    content  = module.eks.aws_auth_configmap_yaml
    filename = "aws_auth_configmap_${terraform.workspace}.yaml"
}

resource "local_file" "kubeconfig_EKS_Cluster" {
    content  = "${local.kubeconfig}"
#   filename = "kubeconfig_${local.cluster_name}_${terraform.workspace}"
    filename = "kubeconfig_${terraform.workspace}"
}