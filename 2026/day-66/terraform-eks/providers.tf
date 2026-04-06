terraform {
    required_providers {
        aws = {
            version = ">= 6.28"
            source = "hashicorp/aws"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 2.0"
        }
    }
}

provider "aws" {
    region = var.region
}