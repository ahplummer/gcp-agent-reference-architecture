variable "project_id" {
  description = "GCP project that hosts the lab."
  type        = string
}

variable "region" {
  description = "Region for Agent Runtime and the staging bucket."
  type        = string
  default     = "us-central1"
}

variable "bq_location" {
  description = "BigQuery location. Must match the public source dataset (US) for the copy job."
  type        = string
  default     = "US"
}

variable "billing_account" {
  description = "Billing account ID (XXXXXX-XXXXXX-XXXXXX) for the budget alert."
  type        = string
}

variable "agent_name" {
  description = "Agent name, used in labels and resource names."
  type        = string
  default     = "bq-agent"
}

variable "owner" {
  description = "Owner label value (lowercase, no spaces)."
  type        = string
}

variable "cost_center" {
  description = "Cost-center label value."
  type        = string
  default     = "lab"
}

variable "env" {
  description = "Environment label value."
  type        = string
  default     = "lab"
}

variable "budget_amount_usd" {
  description = "Monthly budget in USD. Alerts fire at 50% and 100%."
  type        = number
  default     = 50
}

variable "extra_apis" {
  description = "Additional APIs to enable, for example telemetry.googleapis.com once confirmed."
  type        = list(string)
  default     = []
}

variable "agent_principal" {
  description = <<-EOT
    IAM member for the deployed agent. Leave empty on the first apply.
    After deploying the agent, set it to the Agent Identity principal, for example
    principal://agents.global.proj-NUM.system.id.goog/resources/aiplatform/projects/NUM/locations/REGION/reasoningEngines/ID
    or, if Agent Identity is off, serviceAccount:service-NUM@gcp-sa-aiplatform-re.iam.gserviceaccount.com
  EOT
  type        = string
  default     = ""
}
