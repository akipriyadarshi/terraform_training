provider "aws" {
  region  = "us-east-2"
}

module "my_vpc" {
  source = "../modules/vpc"
  #version = "1.0"
  vpc_cidr = "192.168.0.0/16"
  tenancy = "default"
  vpc_id = "${module.my_vpc.vpc_id}"
  #subnet_cidr_public =  "10.0.0.0/17"
  #subnet_cidr_private = "10.0.128.0/17"
}

module "my_ec2" {
    source = "../modules/ec2"
    # for_each = {
    #   one = "${module.my_vpc.subnet_id_public}"
    #   two = "${module.my_vpc.subnet_id_private}"
    # }
    ami_id = "ami-077e31c4939f6a2f3"
    subnet_id_public = "${module.my_vpc.subnet_id_public}"
    subnet_id_private  ="${module.my_vpc.subnet_id_private}"
  
}

module "my_s3" {
 source = "../modules/s3"
 acl = "public-read"
 bucket = "terraakash-2-bucket"  
}