output "project_number" {
  value = data.google_project.this.number
}

output "staging_bucket" {
  description = "Pass to the ADK deploy as the staging bucket."
  value       = "gs://${google_storage_bucket.staging.name}"
}

output "dataset" {
  value = "${var.project_id}.${google_bigquery_dataset.lab.dataset_id}"
}

output "agent_principal" {
  description = "Principal the IAM grants are bound to (empty until the second apply)."
  value       = var.agent_principal
}
