terraform {
  cloud {
    organization = "my_iac_projects"
    workspaces {
      project = "Automated CICD Pipeline"
      name    = "automated-cicd"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
  }

  required_version = ">=1.14.9"
}
