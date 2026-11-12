# Grants for the deployed agent. Nothing is created until var.agent_principal
# is set (second apply, after the agent deploy). Redeploying the agent creates
# a new principal, so update the variable and apply again after each redeploy.

locals {
  agent_project_roles = [
    "roles/mcp.toolUser",      # call the managed BigQuery MCP server
    "roles/bigquery.jobUser",  # run queries
    "roles/aiplatform.user",   # call Gemini / Model Garden models
    "roles/cloudtrace.agent",  # send traces
    "roles/logging.logWriter", # send logs
  ]
}

resource "google_project_iam_member" "agent" {
  for_each = var.agent_principal == "" ? toset([]) : toset(local.agent_project_roles)

  project = var.project_id
  role    = each.value
  member  = var.agent_principal
}

# Read access to the lab dataset only.
resource "google_bigquery_dataset_iam_member" "agent_read" {
  count = var.agent_principal == "" ? 0 : 1

  dataset_id = google_bigquery_dataset.lab.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = var.agent_principal
}
