variable aws_access_key {
    default = "AKIAWOONHQDGTG6BXC5F"
}
variable aws_secret_key {
    default = "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"
}
variable "vpc_cidr_block" {
    default = "172.20.0.0/16"
}
variable "vpc_region" {
    default = "us-east-1"
}
variable "public_subnet_1a_az" {
  default = "us-east-1a"
}
variable "private_subnet_1a_az" {
  default = "us-east-1a"
}
variable "private_subnet_cidr_block_1a" {
    default = "172.20.20.0/24"
}
variable "public_subnet_1a_cidr_block" {
    default = "172.20.10.0/24"
}
variable "aws_ami" {
    default = "ami-0c322300a1dd5dc79"
}

variable "key_name" {
    default = "varshneyv"
}





