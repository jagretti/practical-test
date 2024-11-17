# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.name
  version  = var.version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = merge(var.private_subnets, var.public_subnets)
  }

  depends_on = [aws_iam_role.cluster]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# Nodegroup
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default-nodegroup"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnets # Workers only in private subnet
  instance_types  = ["t3.medium"]       # Default, just making it visible
  launch_template {
    name    = aws_launch_template.default.name
    version = aws_launch_template.default.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "node_role" {
  name = "node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# Default Launch template

resource "aws_launch_template" "default" {
  name = "default"

  vpc_security_group_ids = [aws_security_group.nodes_sg.id]
}

# Security group
# Allows communication between Nodes, Cluster <-> Nodes, and Nodes -> Internet
resource "aws_security_group" "nodes_sg" {
  name        = "eks-default-nodes"
  description = "EKS default nodes SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "eks-default-nodes"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.nodes_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "cluster_to_nodes" {
  security_group_id            = aws_security_group.nodes_sg.id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = [aws_eks_cluster.this.vpc_config.cluster_security_group_id]
}

resource "aws_vpc_security_group_ingress_rule" "nodes_to_nodes" {
  security_group_id            = aws_security_group.nodes_sg.id
  from_port                    = 0
  to_port                      = 0
  ip_protocol                  = "tcp"
  referenced_security_group_id = [aws_security_group.nodes_sg.id]
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.nodes_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
