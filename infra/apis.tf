locals {
  apis = concat([
    "aiplatform.googleapis.com", # Agent Runtime, Gemini, Sessions, Memory Bank
    "bigquery.googleapis.com",   # Lab dataset and the managed MCP server
    "storage.googleapis.com",    # ADK staging bucket
    "cloudtrace.googleapis.com", # ADK OpenTelemetry traces
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "billingbudgets.googleapis.com", # Budget alert
  ], var.extra_apis)
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
