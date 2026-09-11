variable "location" {
  description = "Azure region for the logging foundation"
  type        = string
  default     = "centralus"
}

variable "environment_tag" {
  description = "Tag identifying this as shared platform infra, not project-scoped"
  type        = map(string)
  default = {
    purpose    = "platform-shared"
    scope      = "shared-across-projects"
    costCenter = "platform-shared"
  }
}

variable "daily_quota_gb" {
  description = "Hard daily ingestion cap in GB — cost guardrail, not a production sizing decision"
  type        = number
  default     = 2
}

variable "retention_in_days" {
  description = "Log retention period"
  type        = number
  default     = 30
}