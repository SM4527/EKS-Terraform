# Project Title

EKS-Terraform

## Description

Deploy an EKS K8 Cluster with Self managed Worker nodes on AWS using Terraform.

## Getting Started

### Dependencies

* docker & docker-compose
* aws user with programmatic access and high privileges 
* linux terminal

### Installing

* clone the repository
* set environment variable TF_VAR_AWS_PROFILE
* review terraform variable values in variables.tf, locals.tf, terraform.tfvars

### Executing program

* Configure AWS user with AWS CLI.

```
docker-compose run --rm aws configure --profile $TF_VAR_AWS_PROFILE

docker-compose run --rm aws sts get-caller-identity
```

* Specify appropriate Terraform workspace.

```
docker-compose run --rm terraform workspace show

docker-compose run --rm terraform workspace select default
```

* Run Terraform apply to create the EKS cluster, k8 worker nodes and related AWS resources.

```
./run-docker-compose.sh terraform init

./run-docker-compose.sh terraform validate

./run-docker-compose.sh terraform plan

./run-docker-compose.sh terraform apply
```

* Deploy aws_auth configmap for the TF workspace with updated User, Role & Group mappings.

```
./run-docker-compose.sh kubectl apply -f ./aws_auth_configmap_default.yaml
```

* Verify kubectl calls and ensure Nodes are in Ready state and Pods of daemonset aws-node and kube-proxy and deployment coredns are in Running status.

```
./run-docker-compose.sh kubectl get nodes

./run-docker-compose.sh kubectl get pods -A
```

* Upon initial terraform apply, perform the steps below to migrate TFstate from Local to AWS S3.

```
./run-docker-compose.sh terraform init -force-copy
```

* Before terraform destroy, perform the pre-requisite steps below.

In main.tf, change the terraform_state_backend module argument as follows:
```
force_destroy = true
```

Perform terraform apply with resource targetting.
```
./run-docker-compose.sh terraform apply -target module.terraform_state_backend -auto-approve
```

Remove the backend "s3" configuration in backend.tf. Run the below to have terraform copy state file from AWS S3 to Local.
```
./run-docker-compose.sh terraform init -force-copy
```

proceed with Terraform destroy.
```
./run-docker-compose.sh terraform destroy
```

Once Terraform destroy is complete, change the terraform_state_backend module argument in main.tf as follows:
```
force_destroy = false
```

## Help

* aws-eks-nodegroup-create-failed-instances-failed-to-join-the-kubernetes-cluster

```
Issue: Kubectl get nodes does not list the worker nodes.

Fix:
Ensure instance_metadata_tags in metadata options is set to Disabled.
```

References:

https://derflounder.wordpress.com/2022/01/11/amazon-web-servicess-new-ec2-metadata-tag-option-doesnt-allow-spaces-in-tag-names/

https://stackoverflow.com/questions/64515585/aws-eks-nodegroup-create-failed-instances-failed-to-join-the-kubernetes-cluster

## Authors

[Sivanandam Manickavasagam](https://www.linkedin.com/in/sivanandammanickavasagam)

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

* [cloudposse](https://github.com/cloudposse/terraform-aws-s3-bucket)

## Repo rosters

### Stargazers

[![Stargazers repo roster for @SM4527/EKS-Terraform](https://reporoster.com/stars/dark/SM4527/EKS-Terraform)](https://github.com/SM4527/EKS-Terraform/stargazers)
