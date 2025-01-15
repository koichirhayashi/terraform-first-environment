terraform {
  required_version = "~> 1.8.5"
  backend "s3" {
    bucket  = "hayashi-terraform-state"
    region  = "ap-northeast-1"
    key     = "stg.tfstate"
    profile = "terraform-user"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}