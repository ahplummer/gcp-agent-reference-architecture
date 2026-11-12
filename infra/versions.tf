terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0"
    }
  }
}

locals {
  labels = {
    agent         = var.agent_name
    owner         = var.owner
    "cost-center" = var.cost_center
    env           = var.env
  }
}

# user_project_override + billing_project make user credentials (ADC) bill API
# calls such as Billing Budgets to the lab project instead of failing on quota.
provider "google" {
  project               = var.project_id
  region                = var.region
  default_labels        = local.labels
  user_project_override = true
  billing_project       = var.project_id
}

provider "google-beta" {
  project               = var.project_id
  region                = var.region
  default_labels        = local.labels
  user_project_override = true
  billing_project       = var.project_id
}
