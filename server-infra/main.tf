terraform {
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.63.0"
      }
    }
}

provider "aws" {
    profile = "default"
    region = "${var.region}"

    default_tags {
      tags = {
          Terraform         = "true"
          Region            = var.region
          Project           = var.project_name
      }
    }   
}