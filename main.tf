# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
provider "aws" {
  region  = var.region
}

terraform {
/*
  cloud {
    organization = "davewang"

    workspaces {
      name = "terraform-mlops"
    }
  }
*/
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.14.0"
}