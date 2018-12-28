provider "aws" {
  region = "us-east-2"
}

variable "instance_type" {
  default = "c4.large"
}

variable "region" {
  default = "us-east-2"
}

variable "azs" {
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "environment" {
  default = "staging"
}

variable "role" {
  default = "etcd3-test"
}

variable "ami" {
  default = "ami-0fd1c9a63f8fdb8a5"
}

variable "vpc_cidr" {
  default = "10.200.0.0/16"
}

variable "dns" {
  type = "map"

  default = {
    domain_name = "example.com"
  }
}

variable "root_key_pair_public_key" {}

variable "etcd_cluster_size" {
  default = 3
}

variable "sensu_backend_cluster_size" {
  default = 3
}

variable "ntp_host" {
  default = "0.us.pool.ntp.org"
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}