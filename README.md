# eks-vpc-fargate
To facilitate learning and practice with Amazon Elastic Kubernetes Service (EKS)
Begin by creating a Virtual Private Cloud (VPC) with two public subnets and two private subnets. Additionally, add a NAT gateway to enable outbound internet access. Ensure that you create separate route tables for the public and private subnets.

Next, create the necessary IAM roles for the EKS cluster and node groups. These roles will grant the required permissions for the cluster and its worker nodes to interact with other AWS services.

Don't forget to create an IAM role specifically for the Fargate profile. This role will define the permissions for Fargate tasks running within the EKS cluster.

Finally, execute the setup and obtain the outputs. These outputs will provide information about the resources created during the setup process, allowing you to verify the successful creation of the VPC, subnets, NAT gateway, IAM roles, EKS cluster, and Fargate profile.

By following these steps, you can effectively learn and practice working with Amazon EKS.
