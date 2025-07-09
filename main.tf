# main.tf - Simple PHI S3 Bucket Configuration for MVP

# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend configuration for state management
  backend "s3" {
    bucket = "mvp-phi-storage-terraform-state"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure AWS Provider with your region
provider "aws" {
  region = var.aws_region
}

# S3 bucket for Terraform state (standard bucket, not using PHI module)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "mvp-phi-storage-terraform-state"
  
  tags = merge(local.common_tags, {
    Name = "Terraform State Bucket"
  })
}

# Enable versioning for state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access for state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Variables for customization
variable "aws_region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging and naming"
  type        = string
  default     = "mvp-phi-storage"
}

variable "notification_email" {
  description = "Email for security notifications"
  type        = string
  default     = "security@example.com"
}

# Local values for consistent naming
locals {
  bucket_name = "${var.project_name}-${var.environment}-phi-data"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Purpose     = "PHI Data Storage"
  }
}

# PHI S3 Bucket Module
module "phi_bucket" {
  source  = "github.com/phin3has/PHI-s3-bucket?ref=v1.0.2"
  
  # Basic bucket configuration
  bucket_name = local.bucket_name
  environment = var.environment
  
  # Notification settings
  notification_email = var.notification_email
  
  # Tags
  tags = local.common_tags
}

# Outputs for reference
output "bucket_id" {
  description = "The ID of the PHI S3 bucket"
  value       = module.phi_bucket.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the PHI S3 bucket"
  value       = module.phi_bucket.bucket_arn
}
