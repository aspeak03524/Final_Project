# AWS Region variable
variable "region" {
  description = "The AWS region to create resources in."
  default     = "ap-northeast-3"
}

# VPC CIDR block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

# Public Subnet CIDR blocks
variable "public_subnet_1_cidr" {
  description = "The CIDR block for the first public subnet."
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "The CIDR block for the second public subnet."
  default     = "10.0.2.0/24"
}

# Availability Zones for public subnets
variable "availability_zone_1" {
  description = "The availability zone for the first public subnet."
  default     = "ap-northeast-3a"
}

variable "availability_zone_2" {
  description = "The availability zone for the second public subnet."
  default     = "ap-northeast-3b"
}

# EKS Cluster and Node Group names
variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  default     = "expense-tracker-cluster"
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  default     = "expense-tracker-node-group"
}

# Node group scaling configuration
variable "node_group_desired_size" {
  description = "The desired number of instances in the node group."
  default     = 2
}

variable "node_group_max_size" {
  description = "The maximum number of instances in the node group."
  default     = 4
}

variable "node_group_min_size" {
  description = "The minimum number of instances in the node group."
  default     = 2
}

# Instance types for the node group
variable "node_instance_types" {
  description = "The types of instances for the node group."
  default     = ["t3.medium"]
}

# IAM Role policy attachments for EKS Cluster and Node Group
variable "iam_role_policy_attachment_eks_cluster" {
  description = "IAM role policy attachments for EKS Cluster."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}

variable "iam_role_policy_attachment_eks_nodegroup" {
  description = "IAM role policy attachments for EKS Node Group."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

# Custom AMI ID for the node group (if using a custom AMI)
variable "custom_ami_id" {
  description = "Custom AMI ID for the EKS Node Group."
  type        = string
  default     = "ami-091f18e98bc129c4e"
}

# EC2 Key Pair for SSH access (if needed)
variable "key_name" {
  description = "The EC2 Key Pair to allow SSH access to the instances."
  type        = string
  default     = "your-ssh-key-name" # Replace with your SSH key name
}
