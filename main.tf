data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.2.0"
  # insert the required variables here
  cluster_name  = "${local.cluster_name}"
  cluster_version = var.cluster_version
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1810
  # service-controller  Error syncing load balancer: failed to ensure load balancer: Multiple tagged security groups found for instance
  # ensure only the k8s security group is tagged; the tagged groups were worker-group-1-node-group-* & Default-EKS-Cluster-node-*
  self_managed_node_group_defaults = {
    security_group_tags = {
      "kubernetes.io/cluster/${local.cluster_name}" = null
    }
  }

  self_managed_node_groups = {  

    worker_group = {
      name = "worker-group-1"
      instance_type = var.Instance_Type
      min_size = var.ASG_Min
      desired_size  = var.ASG_Desired
      max_size = var.ASG_Max
      autoscaling_enabled = true
      public_ip = false

      # https://derflounder.wordpress.com/2022/01/11/amazon-web-servicess-new-ec2-metadata-tag-option-doesnt-allow-spaces-in-tag-names/
      # https://stackoverflow.com/questions/64515585/aws-eks-nodegroup-create-failed-instances-failed-to-join-the-kubernetes-clust
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags   = "disabled"
      }
      
      # Extend node-to-node security group rules
      # https://aws.amazon.com/premiumsupport/knowledge-center/eks-metrics-server/
      # https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
      # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/self_managed_node_group/main.tf
      # Metrics server security group to poll the worker nodes & pods and make top node & top pod work.
      security_group_rules = {
        inbound = {
          description = "Worker_node_to_worker_node_inbound"
          protocol    = "tcp"
          from_port   = 1025
          to_port     = 65535
          type        = "ingress"
          cidr_blocks = ["${local.vpc_cidr}"]
        },
        inbound_443 = {
          description = "Worker_node_to_worker_node_inbound_443"
          protocol    = "tcp"
          from_port   = 443
          to_port     = 443
          type        = "ingress"
          cidr_blocks = ["${local.vpc_cidr}"]
        },
        outbound = {
          description = "Worker_node_to_worker_node_outbound"
          protocol    = "all"
          from_port   = 0
          to_port     = 65535
          type        = "egress"
          cidr_blocks = ["${local.vpc_cidr}"]
        }
      }

      # Cluster Autoscaler
      # https://stackoverflow.com/questions/58034203/kubernetes-autoscaler-nottriggerscaleup-pod-didnt-trigger-scale-up-it-would
      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "TRUE"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }

    }
  }
} 

# Cluster Autoscaler
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
# See 2. For addtional IAM policies, users can attach the policies outside of the cluster definition as demonstrated below
resource "aws_iam_role_policy_attachment" "additional" {
        for_each =  module.eks.self_managed_node_groups
        # you could also do the following or any comibination:
        # for_each = merge(
        #   module.eks.eks_managed_node_groups,
        #   module.eks.self_managed_node_group,
        #   module.eks.fargate_profile,
        # )

        #            This policy does not have to exist at the time of cluster creation. Terraform can
        #            deduce the proper order of its creation to avoid errors during creation
        policy_arn = aws_iam_policy.autoscaler_policy.arn 
        role       = each.value.iam_role_name
      }

 # You cannot create a new backend by simply defining this and then immediately proceeding to "terraform apply". The S3 backend must
 # be bootstrapped according to the simple yet essential procedure in https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
 module "terraform_state_backend" {
   source = "cloudposse/tfstate-backend/aws"
   # Cloud Posse recommends pinning every module to a specific version
   # version     = "x.x.x"
   namespace  = ""
   stage      = ""
   name       = "terraform-${local.cluster_name}-.tfstate"
   attributes = ["state"]

   profile = "${var.AWS_PROFILE}"

   terraform_backend_config_file_path = "."
   terraform_backend_config_file_name = "backend.tf"
   force_destroy                      = false
 }