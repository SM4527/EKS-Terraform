resource "kubectl_manifest" "aws_auth_configmap" {

  depends_on = [data.aws_eks_cluster_auth.this]

  yaml_body = module.eks.aws_auth_configmap_yaml
  
}