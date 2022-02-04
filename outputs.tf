output "aws_eks_cluster" {
  description = "kubeconfig"
  value  = "${local.kubeconfig}"
  sensitive = true
}

output "s3_bucket_name" {
  value       = module.terraform_state_backend.s3_bucket_domain_name
  description = "S3 bucket name"
}

output "s3_tfstate_file_name" {
  value       = "terraform.tfstate"
  description = "S3 terraform state file name"
}

output "EKS_cluster_id" {
  value       = module.eks.cluster_id
  description = "EKS_cluster_id"
  sensitive = true
}

output "EKS_cluster_name" {
  value       = "${local.cluster_name}"
  description = "EKS_cluster_name"
  sensitive = true
}

output "EKS_cluster_endpoint" {
  value       = data.aws_eks_cluster.this.endpoint
  description = "EKS_cluster_endpoint"
  sensitive = true  
}

/**
output "EKS_cluster_auth_token" {
  value       = data.aws_eks_cluster_auth.this.token
  description = "EKS_cluster_auth_token"
  sensitive = true
}
**/

output "EKS_cluster_CA_data" {
  value       = data.aws_eks_cluster.this.certificate_authority.0.data
  description = "EKS_cluster_CA_data"
  sensitive = true
}