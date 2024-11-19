variable "name" {
  type = string
  description = "Name of the project"
}

variable "region" {
  type = string
  description = "Name of the region"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone within the region, used for ebs volume"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for vpc. ex: 10.0.0.0/16"
}

# variable "private_subnet_config" {
#   type = map(any)       # (any) means that's going to accept any type of values
#   description = "This map variable contains all the required variables for the private subnet resource"
# }

variable "public_subnet_config" {
  type = map(any)       # (any) means that's going to accept any type of values
  description = "This map variable contains all the required variables for the public subnet resource"
   default = {
   count = [2]
   CIDRs = ["10.0.1.0/24", "10.0.2.0/24"]
   AZs = ["us-west-a1", "us-west-1c"]
 }
}

variable "ec2_config" {
  type = map(any)
}

variable "lb_config" {
  type = map(any)
}

variable "volume_type" {
  type = string
}

variable "desired_size" {
}

variable "max_size" {
}

variable "min_size" {
}

variable "max_unavailable" {
}
