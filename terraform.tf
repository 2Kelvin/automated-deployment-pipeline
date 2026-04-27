terraform {
  cloud {
    organization = "my_iac_projects"
    workspaces {
      project = "CICD Pipelines"
      name    = "full-cicd"
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
 