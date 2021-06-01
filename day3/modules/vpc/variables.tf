variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "tenancy" {
 default = "dedicated" 
}

variable "vpc_id" {
  
}

variable "subnet_cidr_public" {
  default =  "10.0.8.0/24"
}

variable "subnet_cidr_private" {
  default = "10.0.128.0/17"
}