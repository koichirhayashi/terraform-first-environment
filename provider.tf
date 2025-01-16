provider "aws" {
  region = var.region
}
terraform {
  required_version = "~> 1.8.0" # Terraform全体のバージョンを制御
}
