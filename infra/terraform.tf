terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.96"
    }
  }
  backend "s3" {
    bucket         = ""
    key            = ""
    region         = ""
    dynamodb_table = ""
    encrypt        = "true"
  }

}

provider "aws" {
  region = var.aws_region
}