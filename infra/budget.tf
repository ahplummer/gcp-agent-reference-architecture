data "google_project" "this" {
  project_id = var.project_id
}

# Alerts at 50% and 100% of the budget ($25 / $50 by default). Alerts go to
# billing account admins by email. A budget does not stop spending.
resource "google_billing_budget" "lab" {
  billing_account = var.billing_account
  display_name    = "${var.agent_name} lab budget"

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount_usd)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }

  threshold_rules {
    threshold_percent = 1.0
  }

  depends_on = [google_project_service.apis]
}
