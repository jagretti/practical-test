module "vpc" {
  source = "../modules/vpc"

  name = "webapp-vpc"
}

module "eks_cluster" {
  source = "../modules/eks-cluster"

  name    = "webapp-cluster"
  version = "1.31"

  vpc_id          = module.vpc.id
  vpc_cidr        = module.vpc.cidr
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
}
