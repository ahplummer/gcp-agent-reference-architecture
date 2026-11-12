# gcp-harness

A lab reference implementation of one governed AI agent on Google Cloud: an ADK agent on Agent Runtime that answers questions from a BigQuery dataset through Google's managed BigQuery MCP server.

This repo currently holds the stripped-down baseline: the Terraform for the project plumbing. The agent code, Agent Gateway, Model Armor, and Agent Registry entries come later.

- Architecture, component choices, and open questions: [docs/reference-architecture.md](docs/reference-architecture.md)
- Vocabulary and old/new Google product names: [docs/terms.md](docs/terms.md)

## What the Terraform creates

| File | Resources |
|---|---|
| `infra/versions.tf` | `google` and `google-beta` providers (~> 7.0), default labels on every resource: `agent`, `owner`, `cost-center`, `env` |
| `infra/apis.tf` | 10 project APIs (Agent Platform, BigQuery, Storage, Trace, Logging, Monitoring, IAM, Resource Manager, Service Usage, Billing Budgets) |
| `infra/storage.tf` | Staging bucket for the ADK deploy (uniform access, public access blocked, objects deleted after 30 days) |
| `infra/bigquery.tf` | `agent_lab` dataset, plus a one-time query job that copies 50,000 rows of `bigquery-public-data.thelook_ecommerce.orders` into `agent_lab.orders` |
| `infra/iam.tf` | Grants to the agent principal: `mcp.toolUser`, `bigquery.jobUser`, `aiplatform.user`, `cloudtrace.agent`, `logging.logWriter` on the project, and `bigquery.dataViewer` on the lab dataset only. Created only once `agent_principal` is set. |
| `infra/budget.tf` | Monthly budget with email alerts at 50% and 100% ($25 / $50 by default) |
| `infra/outputs.tf` | Project number, staging bucket, dataset ID, agent principal |

Not included yet: Agent Gateway, Model Armor, Agent Registry entries, Gemini Enterprise, the agent itself. The agent deploy stays in the ADK CLI until Terraform's Agent Runtime resource is confirmed to handle ADK source.

## Prerequisites

- Terraform 1.13.3 (pinned in `.tool-versions`)
- `gcloud`, logged in with Application Default Credentials:
  ```sh
  gcloud auth login
  gcloud auth application-default login
  ```
- A project with billing enabled
- On that project and its billing account: permission to enable APIs, create buckets and datasets, set IAM, and create budgets (Billing Account Administrator or Billing Account Costs Manager)

## Run order

Terraform runs twice. The agent's identity doesn't exist until the agent is deployed, so the IAM grants come in the second apply.

**1. First apply: APIs, bucket, dataset, budget**

```sh
cd infra
cp terraform.tfvars.example terraform.tfvars   # fill in project_id, billing_account, owner
terraform init
terraform apply
```

**2. Enable the BigQuery MCP server**

This is a preview feature without a confirmed Terraform resource. The command below is the one from Google's MCP announcement; check the current form before running it.

```sh
gcloud beta services mcp enable bigquery.googleapis.com --project=PROJECT_ID
```

**3. Deploy the agent with the ADK CLI**

Use the `staging_bucket` output for the deploy's staging bucket. Turn on Agent Identity at deploy time if it isn't the default.

**4. Second apply: grant IAM to the agent**

Set `agent_principal` in `terraform.tfvars` to the deployed agent's principal, then apply again:

```hcl
# Agent Identity
agent_principal = "principal://agents.global.proj-NUM.system.id.goog/resources/aiplatform/projects/NUM/locations/REGION/reasoningEngines/ID"

# Or, if Agent Identity is off, the Agent Runtime service agent
agent_principal = "serviceAccount:service-NUM@gcp-sa-aiplatform-re.iam.gserviceaccount.com"
```

```sh
terraform apply
```

**5. After every redeploy**

Redeploying the agent creates a new principal, and the old grants stop applying. Update `agent_principal` and apply again.

## Switching the model

The model is chosen in the agent code from an environment variable (`AGENT_MODEL`), not in Terraform. Terraform only grants access (`roles/aiplatform.user`). Claude through Model Garden also needs a one-time enablement in the console (accept Anthropic's terms) and a regional quota. See the "Model switch" row in section 3 of the reference architecture.

## Cost

About $1–10 a month for light lab use. The main risk is a warm Agent Runtime instance (about $275/month at the default 4 vCPU / 4 GiB). Delete the agent deployment between sessions. See section 7 of the reference architecture.

## Teardown

Delete the Agent Runtime deployment first (console, or the Agent Platform SDK), then:

```sh
cd infra
terraform destroy
```

`terraform destroy` removes the bucket (and its contents), the dataset (and its tables), the IAM grants, and the budget. It leaves the APIs enabled.

## To verify

- `roles/mcp.toolUser` is the current role name for calling managed MCP servers.
- The `gcloud beta services mcp enable` command in step 2.
- Whether `telemetry.googleapis.com` is needed for ADK's OpenTelemetry export (add it through `extra_apis`).
- The Agent Identity principal format, and whether it has to be turned on at deploy time.
