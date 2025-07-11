# variables.tf - Variable definitions for PHI S3 Bucket Configuration

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "944737299127"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "Replica AWS region for bucket replication"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "object_lock_retention_days" {
  description = "Number of days for object lock retention"
  type        = number
  default     = 30
}

variable "object_lock_mode" {
  description = "Object lock retention mode (COMPLIANCE or GOVERNANCE)"
  type        = string
  default     = "COMPLIANCE"
  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.object_lock_mode)
    error_message = "Object lock mode must be either COMPLIANCE or GOVERNANCE."
  }
}
