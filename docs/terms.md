# Terms

Two parts: general agent vocabulary, then common enterprise AI platform terms mapped to Google products.

## General vocabulary

| Term | Meaning | Example |
|---|---|---|
| Model | The LLM itself. It takes text (and images) in and returns text out. It has no tools, memory, or permissions of its own. | Gemini Flash, Claude, Qwen 8B |
| Agent | A model plus instructions, tools, and a loop that lets it decide which tool to call next until the task is done. | An ADK agent that queries BigQuery and summarizes the result |
| Harness | The code that runs the agent loop: builds the prompt, dispatches tool calls, manages context and memory, and enforces permissions. Swap the model and the harness stays. | Claude Code, OpenClaw, Hermes, ADK's runner |
| Runtime | Where the agent process is hosted and scaled. | Agent Runtime, Cloud Run, GKE, a Mac Mini |
| Tool | A function the agent can call. | `run_query`, `send_email` |
| MCP (Model Context Protocol) | A standard protocol for exposing tools and data to agents. An MCP server publishes tools; the agent is the client. | BigQuery managed MCP server |
| A2A (Agent2Agent) | A protocol for one agent to call another agent. | A Gemini Enterprise agent calling a SaaS vendor's agent |
| Skill | A packaged set of instructions (and sometimes scripts) that an agent loads for a specific task. | A time-tracking skill |
| Session | The history of one conversation. | Agent Platform Sessions |
| Memory | Facts kept across conversations. | Agent Platform Memory Bank |
| Grounding / RAG | Pulling in trusted data at answer time so the model answers from it instead of from training data. | Agent Search, Agent Retrieval |
| Registry | A catalog of approved agents, tools, and MCP servers that policy can check against. | Agent Registry |
| Gateway | A network enforcement point for agent traffic: identity, allow/deny, content inspection. | Agent Gateway |
| Control plane | The set of services that decide and enforce policy, as opposed to the agents doing the work (the data plane). | Gateway + Identity + IAM + Model Armor |
| Archetype / reference architecture | The standard, approved shape of a solution that teams copy. | [reference-architecture.md](reference-architecture.md) |

## Sessions vs. Memory Bank

| | n8n Postgres Chat Memory | Agent Platform Sessions | Agent Platform Memory Bank |
|---|---|---|---|
| Stores | Raw message history, keyed by session ID | Raw message history (events) plus session state, keyed by user and session | Short facts pulled out of conversations ("prefers Terraform," "uses us-central1") |
| Lifespan | One conversation, unless the key is reused | One conversation | Across all of a user's conversations |
| How it's written | Every message appended | Every event appended | A model reads the finished session, extracts facts, and merges them with what's stored (updates or drops facts that conflict) |
| How it's read | Last N messages loaded into the prompt | ADK loads the session history | Similarity search for relevant facts, injected into the prompt by an ADK memory tool |
| Who runs it | You (your Postgres) | Google | Google |
| Cost | Your database | Storage plus tiny per-operation fees | The same, plus model tokens for extracting facts |

- **Sessions** = n8n's Postgres Chat Memory, run for you by Google. On by default for agents deployed to Agent Runtime.
- **Memory Bank** is closer to n8n's Zep memory option, or a tool like Mem0: it remembers what it learned about the user, not the transcript. Optional.
- **Hospitality concern:** facts Memory Bank extracts about a guest are personal data. The archetype needs rules for what the agent may remember, retention, and how a guest's memories get deleted.

## Platform terms mapped to Google products

| Term | Meaning | Closest Google product(s) | Notes |
|---|---|---|---|
| Gemini Enterprise | The enterprise AI platform | Two products share the name. **Gemini Enterprise** is the employee-facing app (formerly Agentspace). **Gemini Enterprise Agent Platform** is the developer platform (formerly Vertex AI, renamed 2026-04-22). | "Build the agentic platform on Gemini Enterprise" usually means the Agent Platform for building and running agents, with the app as the employee front door. |
| AI harness | The shared platform every agent uses: registry, standards, runtime, intelligence layer | Google has no product called a harness. The parts are ADK (agent loop and tool dispatch), Agent Runtime (hosting), Sessions, and Memory Bank. | Used here at platform scale to mean the paved road, broader than the agent-loop meaning above. |
| Registry | Catalog of approved agents and tools | **Agent Registry** | Agents register automatically on deploy; MCP servers, endpoints, and skills (preview) are registered manually. |
| AI control plane | Security and policy across systems | **Agent Gateway** + **Agent Identity** + IAM + **Model Armor**, with Agent Registry as the source of truth | Google sells these as separate parts, not one product. The cross-cloud gateway (Envoy-based) is "coming soon," so non-Google systems need their own controls for now. |
| Intelligence layer / context layer | Shared knowledge and grounding, so each agent doesn't rebuild context | Agent Search (formerly Vertex AI Search), Agent Retrieval (formerly Vector Search 2.0), Memory Bank, BigQuery | Not a Google term. Build vs. buy is a separate decision from the agent platform. |
| Archetype | The standard shape of an agent deployed in Google | No product by that name. The nearest is Application Design Center templates (they provision Agent Gateway, Model Armor, and IAM). | An EA term. The reference architecture is a candidate archetype. |
| Agent | A deployed AI application that uses tools | An ADK agent hosted on Agent Runtime and registered in Agent Registry | |
| Model | The LLM behind an agent | Gemini models, plus 200+ others in **Model Garden** | Model Garden is a model catalog. Being listed there doesn't by itself decide where data goes; Google Cloud's service terms and controls like VPC Service Controls do that. A partner model such as Claude called through Model Garden runs under those terms, IAM, audit logs, and GCP billing. |
| MCPs | MCP servers that teams stand up | Google-managed remote MCP servers (BigQuery, Maps, GCE, GKE) plus custom ones, all registered in Agent Registry | Without a registry and gateway, MCP servers spread without standards. |
| Serverless / Cloud Run | Managed runtimes that a Kubernetes-standard shop's security tooling may not reach | Agent Runtime is also a managed serverless runtime | The main tension. See section 4 of the reference architecture. |
| PDLC | Product development lifecycle; the hands-on build side of AI | n/a | EA's part is patterns and proofs of concept. |

## Old and new Google names

| Old name | Current name |
|---|---|
| Vertex AI Platform | Gemini Enterprise Agent Platform |
| Vertex AI Agent Engine | Agent Runtime |
| Agent Engine Sessions / Memory Bank / Code Execution | Agent Platform Sessions / Memory Bank / Code Execution |
| Vertex AI Studio | Agent Studio |
| Vertex AI Model Garden | Agent Platform Model Garden |
| Vertex AI Search | Agent Search |
| Vertex AI Vector Search 2.0 | Agent Retrieval |
| Gen AI evaluation service | Agent Platform Evals |
| Agentspace | Gemini Enterprise (the app) |

Source: [Gemini Enterprise Agent Platform name changes](https://docs.cloud.google.com/gemini-enterprise-agent-platform/vertex-ai-name-changes). Agentspace isn't in that table; that row comes from secondary sources.
