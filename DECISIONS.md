# DECISIONS.md

Living log of architectural decisions for `azure-platform-centralized-logging`. 
Entries are appended in the order decisions were actually made — including 
decisions that were later revised — rather than rewritten to look pre-planned.

---

**Decision: standalone Log Analytics workspace, not reuse of the Hub-and-Spoke 
centralized workspace.**
Hub-and-Spoke's existing `rg-hub-shared-services` workspace was the initial plan 
for this project, since centralizing logs was already a built pillar of that 
architecture. Reconsidered after flagging Hub-and-Spoke's ongoing cost — though 
on inspection, that cost is almost entirely Azure Firewall Standard and Bastion 
Standard billing hourly regardless of traffic, not the workspace itself (Log 
Analytics ingestion is consumption-based and cheap at portfolio-lab volume). 
Chose to decouple anyway, for reasons beyond cost: a shared hub workspace ties 
this project's ability to be demoed independently to three other subscriptions 
being live, and commingles ingestion from unrelated projects, undermining clean 
cost attribution per project (a concern directly informed by my Cost Governance 
project). Centralizing all logs into one workspace remains the correct pattern 
for a single company's Azure estate; independent portfolio projects meant to be 
demoed standalone are better served by scoped or purpose-built shared workspaces.

**Cost flag (cross-project, not addressed in this repo's scope):** Hub-and-Spoke's 
Firewall/Bastion should be deallocated when not actively being demoed, since they 
bill hourly independent of traffic.

**Decision: separate repo for the workspace, not folded into the observability 
project.**
Initially planned to build the workspace directly inside 
`azure-aks-observability-platform`, reasoning that a resource with no independent 
purpose doesn't need its own repo. Revised after considering that this workspace 
is intended to be reused by future Tier 2 projects, not just this one — at that 
point it stops being a project-scoped detail and becomes shared platform 
infrastructure with its own lifecycle, the same category as the `omotayotfstate` 
backend. Consuming projects reference it via `terraform_remote_state` rather than 
provisioning their own copy.

**Decision: repo naming.**
Iterated through `azure-platform-logging-foundation` → `azure-platform-logging` → 
`azure-platform-centralized-logging`. Final name chosen to describe the purpose 
plainly without an unnecessary "foundation" qualifier. Resource group 
(`rg-platform-logging`) and workspace (`law-platform-shared`) names were not 
changed to match, since they name the resource's purpose, not the repo.

**Decision: 30-day retention, with a daily ingestion quota as a cost guardrail.**
30 days is Log Analytics' included retention tier; anything beyond bills 
separately. Appropriate for a non-continuously-running portfolio lab. A 
production system with compliance-driven retention requirements would justify 
90+ days — noted here as the realistic alternative, not adopted, since it isn't 
justified for this use case. The daily quota (`daily_quota_gb`) is a deliberate 
low ceiling (2GB/day) to catch a misconfigured verbose logging setting upstream 
before it becomes a bill surprise, not a production sizing value.

**Decision: no Data Collection Rules (DCRs) in this repo yet.**
DCRs are opinionated about what gets collected and how it's transformed — a 
per-project concern, not a platform one. Building a shared DCR before any 
consuming project's actual telemetry needs are known would mean guessing. 
Deferred; flagged as a candidate to promote into this repo only if a second 
project needs an identical DCR to the first.

**Decision: shared OIDC app registration (`portfolio-terraform-deployer`) across 
portfolio repos, with one federated credential added per repo/branch, rather than 
a new app registration per project.**
One identity per purpose, scoped via multiple federated credentials, is the 
maintainable pattern — provisioning a new service principal per repo doesn't 
scale past a handful of projects and fragments RBAC auditing. RBAC granted at 
subscription scope (`Contributor`, since Terraform must create the resource group 
itself) plus `Storage Blob Data Contributor` on `omotayotfstate` for state access.

**Decision: `use_azuread_auth = true` on the Terraform backend, kept consistent 
with every other repo in the portfolio.**
Authenticates to the `omotayotfstate` storage account via Azure AD identity 
(OIDC in CI, `az login` session locally) rather than a storage account access 
key — no long-lived keys anywhere in this portfolio's state management, by 
convention established from the first project onward.

**Decision: plan-on-PR, apply-on-merge with a manual approval gate (GitHub 
Environment), even for a two-resource repo.**
Considered skipping CI/CD entirely for a "create once, rarely touch again" 
foundation layer. Chose to keep the same pipeline discipline as larger projects 
anyway — consistency of pattern across the portfolio is itself part of what's 
being evaluated, and cutting corners on a small repo would read as inconsistency 
rather than pragmatism.