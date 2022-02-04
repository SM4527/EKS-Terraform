# List Variable names, Types and default values. Use *.tfvars to override default values.

variable "AWS_PROFILE" {
  description = "AWS profile"
  type=string
}

variable "cluster_version" {
  description = "Version of AWS EKS Cluster."
  type = string
  default = "1.21"
}

variable "Instance_Type" {
  description = "AWS Compute Type for Worker node."
  type = string
  default = "t3.large"
}

variable "ASG_Min" {
  description = "ASG Minimum number of Worker Nodes."
  type = number
  default = 2
}

variable "ASG_Max" {
  description = "ASG Maximum number of Worker Nodes."
  type = number
  default = 12
}

variable "ASG_Desired" {
  description = "ASG Desired number of Worker Nodes."
  type = number
  default = 2
}