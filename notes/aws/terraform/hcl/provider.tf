# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "ABCDEFGHIJKLMNOPQRST"
  secret_key = "QUJDREVGR0hJSktMTU5PUFFSU1+RVVldYWVo"
}
