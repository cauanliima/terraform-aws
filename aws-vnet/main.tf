terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "cauan-terraform-state-2026"
    key          = "aws-vpc/terraform.tfstate"
    region       = "sa-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "sa-east-1"
}

