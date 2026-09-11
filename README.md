# azure-platform-centralized-logging

Shared Azure Log Analytics workspace, deployed as its own independently-lifecycled 
platform repo — provisioned once, consumed by any project that needs a place to 
send diagnostic logs, App Insights telemetry, or AKS platform logs.

## Why this exists

Most of my portfolio projects generate logs or telemetry that need somewhere to land. 
Rather than each project provisioning (and paying for) its own Log Analytics 
workspace, or coupling logging to an unrelated project's lifecycle, this repo treats 
centralized logging as what it actually is: shared platform infrastructure with its 
own lifecycle — the same category as my Terraform state backend (`omotayotfstate`), 
not a dependency of any single application project.

## What it provisions

- One resource group (`rg-platform-logging`)
- One Log Analytics workspace (`law-platform-shared`), with:
  - 30-day retention (cost-conscious default for a non-production lab environment)
  - A hard daily ingestion quota, as a guardrail against runaway costs from a 
    misconfigured upstream logging setting

Deliberately narrow scope — no Data Collection Rules, no alerting, no App Insights 
instances. Those are per-project concerns and live in the repos that consume this 
workspace.

## How other projects consume this

Downstream projects reference this workspace's outputs (`workspace_id`, 
`workspace_customer_id`) via `terraform_remote_state`, pointing their own 
diagnostic settings and Application Insights instances at it rather than 
provisioning a duplicate workspace.

## CI/CD

- OIDC authentication via a shared app registration (`portfolio-terraform-deployer`), 
  reused across my portfolio with one federated credential per repo — rather than a 
  new app registration per project, which doesn't scale past a handful of repos.
- `terraform plan` runs on every PR, posted as a PR comment for review.
- `terraform apply` runs on merge to `main`, gated behind a manual approval step 
  (GitHub Environment), consistent with the pattern used across my other 
  infrastructure repos.
- Terraform state stored remotely in `omotayotfstate`, authenticated via Azure AD 
  (`use_azuread_auth`) — no storage account keys anywhere in this repo.

## Part of a larger portfolio

This repo is the foundation layer for `azure-aks-observability-platform` 
(Application Insights + Log Analytics KQL + Prometheus/Grafana on AKS + 
SLO-driven alerting), and is designed to be reused by future projects that need 
centralized logging without re-provisioning it.