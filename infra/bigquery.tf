resource "google_bigquery_dataset" "lab" {
  dataset_id                 = "agent_lab"
  friendly_name              = "Agent lab data"
  description                = "Read-only copy of a public dataset for the agent lab."
  location                   = var.bq_location
  delete_contents_on_destroy = true

  depends_on = [google_project_service.apis]
}

# Copies a slice of a public retail dataset into the lab dataset so the agent
# reads a table you own. BigQuery jobs are immutable: changing the query needs
# a new job_id (bump the suffix).
resource "google_bigquery_job" "seed_orders" {
  job_id   = "seed_orders_v1"
  location = var.bq_location

  query {
    query          = "SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders` LIMIT 50000"
    use_legacy_sql = false

    destination_table {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.lab.dataset_id
      table_id   = "orders"
    }

    create_disposition = "CREATE_IF_NEEDED"
    write_disposition  = "WRITE_TRUNCATE"
  }
}
