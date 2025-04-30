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
    region         = "eu-west-2"
    dynamodb_table = ""
    encrypt        = "true"
  }

}

provider "aws" {
  region = var.aws_region
}