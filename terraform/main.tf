provider "aws" {
  region = "eu-south-2"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-south-2a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-south-2b"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
}
resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_iam_role" "eks_role" {
  name = "andrew-role6"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_attach_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}
resource "aws_iam_role_policy_attachment" "cluster_attach_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_eks_cluster" "expense_tracker" {
  name     = "andrew-cluster6"
  role_arn = aws_iam_role.eks_role.arn
  
  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.cluster_attach_1,
    aws_iam_role_policy_attachment.cluster_attach_2
  ]
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "andrew-6"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_attach_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_attach_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_attach_3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_eks_node_group" "expense_tracker_node_group" {
  cluster_name    = aws_eks_cluster.expense_tracker.name
  node_group_name = "expense-tracker-node-group"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  # Same public subnets
  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }
  instance_types = ["t3.medium"]
  depends_on = [
    aws_eks_cluster.expense_tracker
  ]
}
