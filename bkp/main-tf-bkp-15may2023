provider "aws" {
  region = "us-east-1"
}

# Create the VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks_vpc"
  }
}

# Create the private and public subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "private_subnet_b"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_b"
  }
}

# Create internet_gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks_igw"
  }
}

# Create rote table
resource "aws_route_table" "eks_public_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
  depends_on = [aws_internet_gateway.eks_igw]
   tags = {
    Name = "eks_public_route"
  }
}

# Add the public subnet association to route table.
resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.eks_public_route.id
  depends_on = [aws_route_table.eks_public_route]
}
resource "aws_route_table_association" "public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.eks_public_route.id
  depends_on = [aws_route_table.eks_public_route]
}


# Create  EIP for nat gateway

resource "aws_eip" "eks_eip" {
vpc = true
depends_on = [aws_vpc.eks_vpc]
tags = {
    Name = "eks_eip"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "eks_nat_gateway" {
  allocation_id = aws_eip.eks_eip.id
  subnet_id = aws_subnet.public_subnet_a.id
  tags = {
    Name = "eks_nat"
  }
   depends_on = [aws_eip.eks_eip, aws_internet_gateway.eks_igw]
   
}

# Create private route table
resource "aws_route_table" "eks_private_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway.id
  }
  depends_on = [aws_nat_gateway.eks_nat_gateway]
  tags = {
    Name = "eks_private_route"
  }
}
# Add the private subnet association to route table.
resource "aws_route_table_association" "private_subnet_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.eks_private_route.id
  depends_on = [aws_route_table.eks_private_route]
}

resource "aws_route_table_association" "private_subnet_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.eks_private_route.id
  depends_on = [aws_route_table.eks_private_route]
}


# Create the eks_firewall

resource "aws_security_group" "eks_firewall" {
  name        = "eks_firewall"
  description = "Allow 443, 22, 3849 and all outbound traffic"
  vpc_id      = aws_vpc.eks_vpc.id

# 'Allow all inbound traffic'
 ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_route_table_association.private_subnet_a, aws_route_table_association.private_subnet_b]
}

# Wait 180 seconds to proceed the further resource creation
resource "time_sleep" "wait_180_seconds" {
  depends_on = [aws_route_table.eks_private_route, aws_route_table.eks_public_route]
  #duration = "180s"
  create_duration ="180s"
}


### EKS Setups

terraform {
 required_providers {
    aws = {
       source = "hashicorp/aws"
       }
 }
}

# Declare the eks role

data "aws_iam_role" "eks-ns" {
  name = "eks-ns"
}

/*
# Create the eks role
resource "aws_iam_role" "eks-iam-role" {
 name = "thehardway-eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

# attach these two policies to role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role.name
}

*/

# Create the aws_eks_cluster
resource "aws_eks_cluster" "thehardway-eks" {
 name = "thehardway-cluster"
 #role_arn = aws_iam_role.eks-iam-role.arn
 role_arn = data.aws_iam_role.eks-ns.arn

 vpc_config {
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  endpoint_private_access = var.private_access
  #endpoint_private_access_cidr_blocks = ["10.0.0.0/16"]
 }

 tags = {
    Terraform   = "true"
    Environment = "dev"
  }
 version = "1.23"
 depends_on = [time_sleep.wait_180_seconds]
 /*depends_on = [
  aws_iam_role.eks-iam-role,
 ]
 */
}


# Declare the IAM role for nodes

data "aws_iam_role" "eks-wn" {
  name = "eks-wn"
}

# Create IAM role for Worker nodes
/*
resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-example"
 
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
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }
*/


# Wait 180 seconds to proceed the further resource creation
resource "time_sleep" "eks_cluster_wait_300_seconds" {
  depends_on = [aws_eks_cluster.thehardway-eks]
  create_duration ="300s"
}
 # Create the worker nodes

 resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.thehardway-eks.name
  node_group_name = "thehardway-workernodes"
  node_role_arn  = data.aws_iam_role.eks-wn.arn
  subnet_ids   = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  #subnet_ids      = aws_subnet.private_subnet_[*].id
  instance_types = ["t2.micro"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
 
  scaling_config {
   desired_size = 2
   max_size   = 2
   min_size   = 1
  }
  depends_on = [time_sleep.eks_cluster_wait_300_seconds, aws_eks_cluster.thehardway-eks]
 /*
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  */
 }


# EKS Cluster Values output

output "endpoint" {
  value = aws_eks_cluster.thehardway-eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.thehardway-eks.certificate_authority[0].data
}

### VPC Out puts
output "vpc_id" {
value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
value = [aws_subnet.public_subnet_b.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
value = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "nat_gw_id" {
value = aws_nat_gateway.eks_nat_gateway.id
}

output "igw_id" {
value = aws_internet_gateway.eks_igw.id
}

