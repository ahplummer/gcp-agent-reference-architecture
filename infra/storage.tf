# Staging bucket the ADK CLI uploads the agent package to during deploy.
resource "google_storage_bucket" "staging" {
  name                        = "${var.project_id}-${var.agent_name}-staging"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true # lab only: lets terraform destroy remove deploy artifacts

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.apis]
}
