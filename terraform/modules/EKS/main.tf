resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.public_subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy]
}

/****************************
        EKS Node Group
*****************************/
resource "aws_iam_role" "nodeGroup_role" {
  name = "${var.name}-nodeGroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodeGroup_role.id
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodeGroup_role.id
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodeGroup_role.id
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.nodeGroup_role.id
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name}-nodes"
  node_role_arn   = aws_iam_role.nodeGroup_role.arn
  subnet_ids      = var.public_subnet_ids
  capacity_type  = "ON_DEMAND"
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}


/****************************
        EKS Dependencies
*****************************/
resource "aws_eks_addon" "cnii" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
}
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
}
resource "aws_eks_addon" "kube-proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
}
resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
}