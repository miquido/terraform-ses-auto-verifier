variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  default     = "ses-auto-verifier"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "bucket_arn" {
  type        = string
  description = "SES bucket arn"
}

variable "bucket_id" {
  type        = string
  description = "SES bucket id"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "log_retention" {
  type        = number
  default     = 7
  description = "Specifies the number of days you want to retain log events in the specified log group"
}
